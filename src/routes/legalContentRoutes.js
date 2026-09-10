const express = require('express');

const router = express.Router();

const legalContentController = require('../controllers/legalContentController');

// Mobile app + admin panel
router.get('/', legalContentController.getLegalContent);

// Admin panel
router.put('/', legalContentController.updateLegalContent);

module.exports = router;