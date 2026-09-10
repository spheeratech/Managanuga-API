const axios = require("axios");

const getPincodeDetails = async (pincode) => {

  const response = await axios.get(
    `https://api.postalpincode.in/pincode/${pincode}`
  );

  const result = response.data?.[0];

  if (
    !result ||
    result.Status !== "Success" ||
    !result.PostOffice ||
    result.PostOffice.length === 0
  ) {
    return null;
  }

  const office = result.PostOffice[0];

  return {
    city: office.District,
    state: office.State,
  };
};

module.exports = {
  getPincodeDetails,
};