const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/languagelearningapp';
        
        // Debug: Show which connection string is being used
        console.log('🔗 Connecting to:', mongoURI.includes('mongodb+srv') ? 'MongoDB Atlas' : 'Local MongoDB');
        console.log('🔗 URI preview:', mongoURI.replace(/\/\/.*:.*@/, '//***:***@'));
        
        const options = {
            // Remove deprecated options for Mongoose 8
        };

        const conn = await mongoose.connect(mongoURI, options);

        console.log(`🗄️  MongoDB Connected: ${conn.connection.host}`);
        console.log(`📋 Database: ${conn.connection.name}`);

        // Handle connection events
        mongoose.connection.on('error', (err) => {
            console.error('❌ MongoDB connection error:', err);
        });

        mongoose.connection.on('disconnected', () => {
            console.log('⚠️  MongoDB disconnected');
        });

        // Graceful shutdown
        process.on('SIGINT', async () => {
            try {
                await mongoose.connection.close();
                console.log('🔌 MongoDB connection closed through app termination');
                process.exit(0);
            } catch (error) {
                console.error('Error closing MongoDB connection:', error);
                process.exit(1);
            }
        });

    } catch (error) {
        console.error('❌ MongoDB connection failed:', error.message);
        
        // Retry connection after 5 seconds
        setTimeout(() => {
            console.log('🔄 Retrying MongoDB connection...');
            connectDB();
        }, 5000);
    }
};

module.exports = connectDB;