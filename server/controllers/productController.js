const Product = require('../models/Product');
const Store = require('../models/Store');
const cloudinary = require('../config/cloudinary');

/*
 * Create Product
 */
exports.createProduct = async (req, res) => {
  try {
    const product = await Product.create(req.body);

    return res.status(201).json({
      message: 'Product created successfully',
      data: product
    });

  } catch (error) {
    console.error(error);

    return res.status(500).json({
      message: error.message
    });
  }
};
/*
 * Get All Products with Pagination and Search
 */
exports.getAllProducts = async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page) || 1, 1);
    const limit = Math.min(parseInt(req.query.limit) || 20, 50);
    const search = req.query.search?.trim();

    const matchStage = search
      ? {
          $match: {
            $or: [
              { name: { $regex: search, $options: 'i' } },
              { 'store.storeName': { $regex: search, $options: 'i' } }
            ]
          }
        }
      : { $match: {} };

    const basePipeline = [
      {
        $lookup: {
          from: 'stores',
          localField: 'storeId',
          foreignField: '_id',
          as: 'store'
        }
      },
      { $unwind: { path: '$store', preserveNullAndEmptyArrays: true } },
      matchStage
    ];

    const countResult = await Product.aggregate([
      ...basePipeline,
      { $count: 'total' }
    ]);
    const totalCount = countResult[0]?.total || 0;
    const totalPages = Math.ceil(totalCount / limit);

    const products = await Product.aggregate([
      ...basePipeline,
      { $sort: { createdAt: -1 } },
      { $skip: (page - 1) * limit },
      { $limit: limit },
      {
        $project: {
          name: 1,
          priceCapital: 1,
          priceSell: 1,
          parcode: 1,
          quantity: 1,
          yearManufacture: 1,
          age: 1,
          size: 1,
          expiryDate: 1,
          categoryId: 1,
          imageUrl: 1,
          createdAt: 1,
          updatedAt: 1,
          storeId: {
            _id: '$store._id',
            storeName: '$store.storeName',
            storeType: '$store.storeType'
          }
        }
      }
    ]);

    return res.status(200).json({
      products,
      page,
      totalPages,
      totalCount,
      hasMore: page < totalPages
    });

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};
/*
 * Get Product By ID
 */
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate('storeId', 'storeName storeType');

    if (!product) {
      return res.status(404).json({
        message: 'Product not found'
      });
    }

    return res.status(200).json(product);

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};

/*
 * Get Products By Store
 */
exports.getProductsByStore = async (req, res) => {
  try {
    const products = await Product.find({
      storeId: req.params.id
    });

    return res.status(200).json(products);

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};
/*
 * Update Product
 */
exports.updateProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!product) {
      return res.status(404).json({
        message: 'Product not found'
      });
    }

    return res.status(200).json({
      message: 'Product updated successfully',
      data: product
    });

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};

/*
 * Delete Product
 */
exports.deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);

    if (!product) {
      return res.status(404).json({
        message: 'Product not found'
      });
    }

    return res.status(200).json({
      message: 'Product deleted successfully'
    });

  } catch (error) {
    return res.status(500).json({
      message: error.message
    });
  }
};
/*
 * Upload Product Image
 */
exports.uploadProductImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        code: 'NO_FILE',
        message: 'No image file provided'
      });
    }

    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({
        code: 'PRODUCT_NOT_FOUND',
        message: 'Product not found'
      });
    }

    // تحقق الملكية: هل صاحب الحساب الحالي فعلاً هو صاحب المتجر بتاع المنتج ده؟
    const store = await Store.findOne({ ownerId: req.user.id });

    if (!store || product.storeId.toString() !== store._id.toString()) {
      return res.status(403).json({
        code: 'FORBIDDEN',
        message: 'You are not authorized to modify this product'
      });
    }

    const uploadResult = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        { folder: 'products' },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(req.file.buffer);
    });

    product.imageUrl = uploadResult.secure_url;
    await product.save();

    return res.status(200).json({
      message: 'Image uploaded successfully',
      data: product
    });

  } catch (error) {
    console.error('[uploadProductImage] Error:', error);
    return res.status(500).json({
      code: 'INTERNAL_ERROR',
      message: error.message
    });
  }

};