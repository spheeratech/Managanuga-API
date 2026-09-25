const Address = require("../models/Address");

const {
  getPincodeDetails: fetchPincodeDetails,
} = require("../services/pincodeService");


const addAddress = async (req, res) => {
  try {
    const {
      user_id,
      entity_id,
    } = req.body;

    /*
     * New API requires public user_id.
     *
     * Legacy entity_id is still accepted temporarily
     * so older frontend versions do not immediately break.
     */
    if (!user_id && !entity_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const address = await Address.createAddress(req.body);

    res.status(201).json({
      success: true,
      message: "Address added successfully",
      data: address,
    });
  } catch (error) {
    console.error("ADD ADDRESS ERROR:", error);

    if (
      error.message &&
      (
        error.message.includes("User not found") ||
        error.message.includes("user_id is required")
      )
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const getAddresses = async (req, res) => {
  try {
    const addresses = await Address.getAddresses(req.query);

    res.status(200).json({
      success: true,
      count: addresses.length,
      data: addresses,
    });
  } catch (error) {
    console.error("GET ADDRESSES ERROR:", error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const getPincodeDetails = async (req, res) => {
  try {
    const { pincode } = req.params;

    if (!/^[0-9]{6}$/.test(pincode)) {
      return res.status(400).json({
        success: false,
        message: "Invalid pincode",
      });
    }

    const data = await fetchPincodeDetails(pincode);

    if (!data) {
      return res.status(404).json({
        success: false,
        message: "Pincode not found",
      });
    }

    res.status(200).json({
      success: true,
      data,
    });
  } catch (error) {
    console.error("PINCODE ERROR:", error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const updateAddress = async (req, res) => {
  try {
    const { id } = req.params;

    const address = await Address.updateAddress(id, req.body);

    if (!address) {
      return res.status(404).json({
        success: false,
        message: "Address not found or no valid fields supplied",
      });
    }

    res.status(200).json({
      success: true,
      message: "Address updated successfully",
      data: address,
    });
  } catch (error) {
    console.error("UPDATE ADDRESS ERROR:", error);

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;

    const address = await Address.deleteAddress(id);

    if (!address) {
      return res.status(404).json({
        success: false,
        message: "Address not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Address deleted successfully",
      data: address,
    });
  } catch (error) {
    console.error("DELETE ADDRESS ERROR:", error);

    // PostgreSQL foreign-key violation
    if (error.code === "23503") {
      return res.status(409).json({
        success: false,
        message:
          "This address is linked to an existing order and cannot be deleted.",
      });
    }

    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


module.exports = {
  addAddress,
  getAddresses,
  getPincodeDetails,
  updateAddress,
  deleteAddress,
};