// Quick script to fix facebookId index issue
const mongoose = require('mongoose');
require('dotenv').config();

async function fixIndex() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    const db = mongoose.connection.db;
    
    // Drop old index
    try {
      await db.collection('users').dropIndex('facebookId_1');
      console.log('✅ Dropped old facebookId_1 index');
    } catch (err) {
      console.log('⚠️  Index facebookId_1 not found or already dropped');
    }
    
    // Create new sparse index
    await db.collection('users').createIndex(
      { facebookId: 1 }, 
      { unique: true, sparse: true }
    );
    console.log('✅ Created new sparse index for facebookId');
    
    await mongoose.disconnect();
    console.log('✅ Done!');
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err);
    process.exit(1);
  }
}

fixIndex();
