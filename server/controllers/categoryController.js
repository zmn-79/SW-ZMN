const Category =
  require('../models/Category');

/*
 * Create Category
 */
exports.createCategory =
  async (req, res) => {

    try {

      const {
        storeId,
        category
      } = req.body;

      // Validation
      if (!storeId || !category) {

        return res.status(400).json({
          message:
            'storeId and category are required'
        });

      }

      const newCategory =
        await Category.create({

          storeId,
          category

        });

      return res.status(201).json({

        message:
          'Category created successfully',

        data:
          newCategory

      });

    } catch (error) {

      console.error(error);

      return res.status(500).json({

        message:
          error.message

      });

    }

};
/*
 * Get Categories By Store
 */
exports.getCategoriesByStore =
  async (req, res) => {

    try {

      const categories =
        await Category.find({
          storeId: req.params.storeId
        });

      return res.status(200).json(categories);

    } catch (error) {

      return res.status(500).json({
        message: error.message
      });

    }

};