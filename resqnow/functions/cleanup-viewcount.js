/**
 * Cleanup script to remove 'viewCount' field from all medical_conditions documents
 *
 * Run this with: node cleanup-viewcount.js
 *
 * Make sure you have:
 * 1. Firebase Admin SDK initialized
 * 2. GOOGLE_APPLICATION_CREDENTIALS environment variable set (or use --project flag)
 */

const admin = require("firebase-admin");

// Initialize Firebase Admin (make sure your credentials are set up)
// Option 1: Using environment variable
// export GOOGLE_APPLICATION_CREDENTIALS="path/to/serviceAccountKey.json"

// Option 2: Initialize with explicit credentials path
const serviceAccount = process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!serviceAccount) {
  console.error(
    "❌ Error: GOOGLE_APPLICATION_CREDENTIALS environment variable not set"
  );
  console.error(
    'Set it with: export GOOGLE_APPLICATION_CREDENTIALS="/path/to/serviceAccountKey.json"'
  );
  process.exit(1);
}

try {
  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccount)),
  });
} catch (error) {
  console.error("❌ Firebase initialization failed:", error.message);
  process.exit(1);
}

const db = admin.firestore();

async function deleteViewCountField() {
  try {
    console.log(
      "🔍 Starting to delete viewCount field from medical_conditions...\n"
    );

    // Get all documents from medical_conditions collection
    const snapshot = await db.collection("medical_conditions").get();

    if (snapshot.empty) {
      console.log("⚠️  medical_conditions collection is empty");
      process.exit(0);
    }

    console.log(`📊 Found ${snapshot.size} documents\n`);

    let deletedCount = 0;
    let skippedCount = 0;
    const batch = db.batch();
    let batchSize = 0;

    // Process documents in batches (Firestore allows max 500 writes per batch)
    snapshot.forEach((doc) => {
      const data = doc.data();

      // Only delete if viewCount field exists
      if (data.hasOwnProperty("viewCount")) {
        console.log(
          `✅ Deleting viewCount from: ${doc.id} (current value: ${data.viewCount})`
        );
        batch.update(doc.ref, {
          viewCount: admin.firestore.FieldValue.delete(),
        });
        deletedCount++;
        batchSize++;

        // Commit batch every 100 updates (safe below 500 limit)
        if (batchSize === 100) {
          batch.commit();
          batchSize = 0;
        }
      } else {
        console.log(`⏭️  Skipping ${doc.id} (no viewCount field)`);
        skippedCount++;
      }
    });

    // Commit remaining writes
    if (batchSize > 0) {
      await batch.commit();
    }

    console.log(`\n✨ Cleanup completed!`);
    console.log(`   Deleted from: ${deletedCount} documents`);
    console.log(`   Skipped: ${skippedCount} documents (no viewCount field)`);
    console.log(`   Total processed: ${snapshot.size} documents`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Error during cleanup:", error.message);
    console.error(error);
    process.exit(1);
  }
}

// Run the cleanup
deleteViewCountField();
