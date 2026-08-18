const multer = require('multer');

// تخزين الملف مؤقتًا في الذاكرة (RAM) بدل القرص الصلب
// السبب: الملف هيترفع فورًا لـ Cloudinary ومش محتاجين نحتفظ بنسخة محلية خالص
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
    'image/gif'
  ];

  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error(`Unsupported image type: ${file.mimetype}`), false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5 ميجابايت كحد أقصى
  }
});

module.exports = upload;