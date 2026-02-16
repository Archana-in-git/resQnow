const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const axios = require("axios");

// Optional: limit scaling
setGlobalOptions({ maxInstances: 10 });

exports.nearbyHospitals = onRequest(async (req, res) => {
  try {
    const { lat, lng } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: "Missing coordinates" });
    }

    const response = await axios.get(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json",
      {
        params: {
          location: `${lat},${lng}`,
          radius: 3500,
          type: "hospital",
          key: process.env.GOOGLE_API_KEY, // 🔐 Secure key
        },
      }
    );

    res.status(200).json(response.data);
  } catch (error) {
    logger.error("Hospital fetch error:", error);
    res.status(500).json({ error: error.message });
  }
});
