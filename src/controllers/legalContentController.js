const LegalContent = require('../models/LegalContent');

// GET LEGAL CONTENT
exports.getLegalContent = async (req, res) => {
  console.log('GET LEGAL CONTENT ROUTE HIT');

  try {
    const legalContent = await LegalContent.get();

    if (!legalContent) {
      return res.status(404).json({
        success: false,
        message: 'Legal content not found',
      });
    }

    res.json({
      success: true,
      data: legalContent,
    });
  } catch (err) {
    console.error('GET LEGAL CONTENT ERROR:', err);

    res.status(500).json({
      success: false,
      message: 'Failed to fetch legal content',
    });
  }
};


// UPDATE LEGAL CONTENT
exports.updateLegalContent = async (req, res) => {
  console.log('UPDATE LEGAL CONTENT ROUTE HIT');
  console.log('BODY:', req.body);

  try {
    const {
      terms_conditions,
      privacy_policy,
      customer_care,
      refund_cancellation_policy,
      shipping_delivery,
    } = req.body;

    // Make sure all fields are present
    if (
      terms_conditions === undefined ||
      privacy_policy === undefined ||
      customer_care === undefined ||
      refund_cancellation_policy === undefined ||
      shipping_delivery === undefined
    ) {
      return res.status(400).json({
        success: false,
        message: 'All legal content fields are required',
      });
    }

    const updatedContent = await LegalContent.update({
      terms_conditions,
      privacy_policy,
      customer_care,
      refund_cancellation_policy,
      shipping_delivery,
    });

    if (!updatedContent) {
      return res.status(404).json({
        success: false,
        message: 'Legal content record not found',
      });
    }

    res.json({
      success: true,
      message: 'Legal content updated successfully',
      data: updatedContent,
    });
  } catch (err) {
    console.error('UPDATE LEGAL CONTENT ERROR:', err);

    res.status(500).json({
      success: false,
      message: 'Failed to update legal content',
    });
  }
};