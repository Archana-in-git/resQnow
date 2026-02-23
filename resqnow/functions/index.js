const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const axios = require("axios");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already done
if (!admin.apps.length) {
  admin.initializeApp();
}

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

// ============================================================================
// 🚨 DELETE FIREBASE AUTH ACCOUNT (Called when admin deletes user)
// ============================================================================
exports.deleteUserAuthAccount = onRequest(async (req, res) => {
  // ✅ CORS handling
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return;
  }

  try {
    // Only allow POST requests
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed. Use POST." });
    }

    const { uid, email } = req.body;

    // Validate input
    if (!uid) {
      return res.status(400).json({ error: "Missing required field: uid" });
    }

    logger.info(`Starting deletion of auth account for UID: ${uid}, Email: ${email}`);

    // Delete the Firebase Auth user account
    await admin.auth().deleteUser(uid);

    logger.info(
      `✅ Successfully deleted Firebase Auth account - UID: ${uid}, Email: ${email}`
    );

    return res.status(200).json({
      success: true,
      message: `Firebase Auth account deleted for UID: ${uid}`,
      uid: uid,
      email: email,
    });
  } catch (error) {
    logger.error(`❌ Error deleting Firebase Auth account:`, error);

    // Check if error is "user not found" - this is not necessarily an error
    if (error.code === "auth/user-not-found") {
      logger.info(`User not found in Firebase Auth (may have been deleted already)`);
      return res.status(200).json({
        success: true,
        message: "User not found in Firebase Auth (may already be deleted)",
      });
    }

    return res.status(500).json({
      success: false,
      error: error.message,
      code: error.code,
    });
  }
});
