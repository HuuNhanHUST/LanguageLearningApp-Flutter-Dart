/**
 * Script to verify and create database indexes for optimal performance
 * Run this script to ensure all indexes are properly created
 */

const mongoose = require('mongoose');
require('dotenv').config();

const User = require('../models/User');
const Word = require('../models/Word');

async function verifyIndexes() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get User indexes
    console.log('\n📊 Checking User collection indexes...');
    const userIndexes = await User.collection.getIndexes();
    console.log('User indexes:', Object.keys(userIndexes));

    // Get Word indexes
    console.log('\n📊 Checking Word collection indexes...');
    const wordIndexes = await Word.collection.getIndexes();
    console.log('Word indexes:', Object.keys(wordIndexes));

    // Create indexes if they don't exist
    console.log('\n🔧 Creating/syncing indexes...');
    await User.syncIndexes();
    console.log('✅ User indexes synced');

    await Word.syncIndexes();
    console.log('✅ Word indexes synced');

    // Verify again
    console.log('\n📊 Final index verification...');
    const finalUserIndexes = await User.collection.getIndexes();
    const finalWordIndexes = await Word.collection.getIndexes();

    console.log('\n✅ Final User indexes:');
    Object.keys(finalUserIndexes).forEach(idx => {
      console.log(`  - ${idx}: ${JSON.stringify(finalUserIndexes[idx].key)}`);
    });

    console.log('\n✅ Final Word indexes:');
    Object.keys(finalWordIndexes).forEach(idx => {
      console.log(`  - ${idx}: ${JSON.stringify(finalWordIndexes[idx].key)}`);
    });

    console.log('\n✅ Index verification completed successfully!');
  } catch (error) {
    console.error('❌ Error verifying indexes:', error);
    throw error;
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Disconnected from MongoDB');
  }
}

// Run if called directly
if (require.main === module) {
  verifyIndexes()
    .then(() => process.exit(0))
    .catch(err => {
      console.error(err);
      process.exit(1);
    });
}

module.exports = verifyIndexes;
