
const { logException } = require("../utils/exceptionLogger.js");
const Address = require("../models/Address");

const {
  getPincodeDetails: fetchPincodeDetails,
} = require("../services/pincodeService");


const addAddress = async (req, res) => {
  try {
    const authenticatedUserId = String(
      req.authenticatedUser.id
    ).trim();

    const address = await Address.createAddress({
      ...req.body,
      user_id: authenticatedUserId,
    });

    return res.status(201).json({
      success: true,
      message: "Address added successfully",
      data: address,
    });
  } catch (error) {
    void logException(error);
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

    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const getAddresses = async (req, res) => {
  try {
    const authenticatedUserId = String(
      req.authenticatedUser.id
    ).trim();

    const addresses = await Address.getAddresses({
      ...req.query,
      user_id: authenticatedUserId,
    });

    return res.status(200).json({
      success: true,
      count: addresses.length,
      data: addresses,
    });
  } catch (error) {
    void logException(error);
    console.error("GET ADDRESSES ERROR:", error);

    return res.status(500).json({
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

    return res.status(200).json({
      success: true,
      data,
    });
  } catch (error) {
    void logException(error);
    console.error("PINCODE ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const updateAddress = async (req, res) => {
  try {
    const { id } = req.params;

    const authenticatedUserId = String(
      req.authenticatedUser.id
    ).trim();

    const address = await Address.updateAddress(
      id,
      req.body,
      authenticatedUserId
    );

    if (!address) {
      return res.status(404).json({
        success: false,
        message: "Address not found or no valid fields supplied",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Address updated successfully",
      data: address,
    });
  } catch (error) {
    void logException(error);
    console.error("UPDATE ADDRESS ERROR:", error);

    return res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};


const deleteAddress = async (req, res) => {
  try {
    const { id } = req.params;

    const authenticatedUserId = String(
      req.authenticatedUser.id
    ).trim();

    const address = await Address.deleteAddress(
      id,
      authenticatedUserId
    );

    if (!address) {
      return res.status(404).json({
        success: false,
        message: "Address not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Address deleted successfully",
      data: address,
    });
  } catch (error) {
    void logException(error);
    console.error("DELETE ADDRESS ERROR:", error);

    if (error.code === "23503") {
      return res.status(409).json({
        success: false,
        message:
          "This address is linked to an existing order and cannot be deleted.",
      });
    }

    return res.status(500).json({
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
