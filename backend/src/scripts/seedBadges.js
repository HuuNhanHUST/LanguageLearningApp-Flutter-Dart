const mongoose = require('mongoose');
const Badge = require('../models/Badge');
require('dotenv').config();

/**
 * Script to seed badges into the database
 * Run with: node src/scripts/seedBadges.js
 */

// Sample badge data
const badges = [
    // XP-based badges
    {
        name: 'Newbie',
        description: 'Đạt 50 XP đầu tiên',
        iconUrl: '/badges/newbie.png',
        criteria: {
            type: 'xp',
            target: 50
        },
        category: 'bronze',
        displayOrder: 1,
        xpBonus: 10
    },
    {
        name: 'Explorer',
        description: 'Đạt 100 XP',
        iconUrl: '/badges/explorer.png',
        criteria: {
            type: 'xp',
            target: 100
        },
        category: 'bronze',
        displayOrder: 2,
        xpBonus: 20
    },
    {
        name: 'Adventurer',
        description: 'Đạt 500 XP',
        iconUrl: '/badges/adventurer.png',
        criteria: {
            type: 'xp',
            target: 500
        },
        category: 'silver',
        displayOrder: 3,
        xpBonus: 50
    },
    {
        name: 'Champion',
        description: 'Đạt 1000 XP',
        iconUrl: '/badges/champion.png',
        criteria: {
            type: 'xp',
            target: 1000
        },
        category: 'gold',
        displayOrder: 4,
        xpBonus: 100
    },
    {
        name: 'Legend',
        description: 'Đạt 5000 XP',
        iconUrl: '/badges/legend.png',
        criteria: {
            type: 'xp',
            target: 5000
        },
        category: 'platinum',
        displayOrder: 5,
        xpBonus: 500
    },
    
    // Vocabulary-based badges
    {
        name: 'Word Collector',
        description: 'Học được 10 từ vựng',
        iconUrl: '/badges/word-collector.png',
        criteria: {
            type: 'words_learned',
            target: 10
        },
        category: 'bronze',
        displayOrder: 10,
        xpBonus: 10
    },
    {
        name: 'Vocabulary Builder',
        description: 'Học được 50 từ vựng',
        iconUrl: '/badges/vocabulary-builder.png',
        criteria: {
            type: 'words_learned',
            target: 50
        },
        category: 'bronze',
        displayOrder: 11,
        xpBonus: 25
    },
    {
        name: 'Word Master',
        description: 'Học được 100 từ vựng',
        iconUrl: '/badges/word-master.png',
        criteria: {
            type: 'words_learned',
            target: 100
        },
        category: 'silver',
        displayOrder: 12,
        xpBonus: 50
    },
    {
        name: 'Vocabulary Expert',
        description: 'Học được 500 từ vựng',
        iconUrl: '/badges/vocabulary-expert.png',
        criteria: {
            type: 'words_learned',
            target: 500
        },
        category: 'gold',
        displayOrder: 13,
        xpBonus: 200
    },
    {
        name: 'Polyglot',
        description: 'Học được 1000 từ vựng',
        iconUrl: '/badges/polyglot.png',
        criteria: {
            type: 'words_learned',
            target: 1000
        },
        category: 'platinum',
        displayOrder: 14,
        xpBonus: 500
    },
    
    // Streak-based badges
    {
        name: 'Consistent Learner',
        description: 'Duy trì streak 3 ngày',
        iconUrl: '/badges/consistent-learner.png',
        criteria: {
            type: 'streak',
            target: 3
        },
        category: 'bronze',
        displayOrder: 20,
        xpBonus: 15
    },
    {
        name: 'Week Warrior',
        description: 'Duy trì streak 7 ngày',
        iconUrl: '/badges/week-warrior.png',
        criteria: {
            type: 'streak',
            target: 7
        },
        category: 'silver',
        displayOrder: 21,
        xpBonus: 30
    },
    {
        name: 'Dedication Master',
        description: 'Duy trì streak 30 ngày',
        iconUrl: '/badges/dedication-master.png',
        criteria: {
            type: 'streak',
            target: 30
        },
        category: 'gold',
        displayOrder: 22,
        xpBonus: 100
    },
    {
        name: 'Unstoppable',
        description: 'Duy trì streak 100 ngày',
        iconUrl: '/badges/unstoppable.png',
        criteria: {
            type: 'streak',
            target: 100
        },
        category: 'platinum',
        displayOrder: 23,
        xpBonus: 500
    },
    
    // Lesson-based badges
    {
        name: 'First Steps',
        description: 'Hoàn thành 5 bài học',
        iconUrl: '/badges/first-steps.png',
        criteria: {
            type: 'lessons_completed',
            target: 5
        },
        category: 'bronze',
        displayOrder: 30,
        xpBonus: 10
    },
    {
        name: 'Diligent Student',
        description: 'Hoàn thành 25 bài học',
        iconUrl: '/badges/diligent-student.png',
        criteria: {
            type: 'lessons_completed',
            target: 25
        },
        category: 'silver',
        displayOrder: 31,
        xpBonus: 50
    },
    {
        name: 'Scholar',
        description: 'Hoàn thành 100 bài học',
        iconUrl: '/badges/scholar.png',
        criteria: {
            type: 'lessons_completed',
            target: 100
        },
        category: 'gold',
        displayOrder: 32,
        xpBonus: 150
    },
    
    // Perfect score badges
    {
        name: 'Perfectionist',
        description: 'Đạt điểm tuyệt đối 5 lần',
        iconUrl: '/badges/perfectionist.png',
        criteria: {
            type: 'perfect_scores',
            target: 5
        },
        category: 'silver',
        displayOrder: 40,
        xpBonus: 30
    },
    {
        name: 'Flawless',
        description: 'Đạt điểm tuyệt đối 20 lần',
        iconUrl: '/badges/flawless.png',
        criteria: {
            type: 'perfect_scores',
            target: 20
        },
        category: 'gold',
        displayOrder: 41,
        xpBonus: 100
    },
    
    // Level-based badges
    {
        name: 'Rising Star',
        description: 'Đạt cấp độ 5',
        iconUrl: '/badges/rising-star.png',
        criteria: {
            type: 'level',
            target: 5
        },
        category: 'bronze',
        displayOrder: 50,
        xpBonus: 25
    },
    {
        name: 'Elite Learner',
        description: 'Đạt cấp độ 10',
        iconUrl: '/badges/elite-learner.png',
        criteria: {
            type: 'level',
            target: 10
        },
        category: 'silver',
        displayOrder: 51,
        xpBonus: 100
    },
    {
        name: 'Master',
        description: 'Đạt cấp độ 15',
        iconUrl: '/badges/master.png',
        criteria: {
            type: 'level',
            target: 15
        },
        category: 'gold',
        displayOrder: 52,
        xpBonus: 250
    },
    {
        name: 'Grandmaster',
        description: 'Đạt cấp độ 20 - Cấp độ tối đa!',
        iconUrl: '/badges/grandmaster.png',
        criteria: {
            type: 'level',
            target: 20
        },
        category: 'platinum',
        displayOrder: 53,
        xpBonus: 1000
    },
    
    // Daily goal badges
    {
        name: 'Goal Getter',
        description: 'Đạt mục tiêu hàng ngày 7 ngày',
        iconUrl: '/badges/goal-getter.png',
        criteria: {
            type: 'daily_goal',
            target: 7
        },
        category: 'silver',
        displayOrder: 60,
        xpBonus: 40
    },
    {
        name: 'Goal Master',
        description: 'Đạt mục tiêu hàng ngày 30 ngày',
        iconUrl: '/badges/goal-master.png',
        criteria: {
            type: 'daily_goal',
            target: 30
        },
        category: 'gold',
        displayOrder: 61,
        xpBonus: 150
    },
    
    // Special badges
    {
        name: 'Early Bird',
        description: 'Người dùng đầu tiên của hệ thống',
        iconUrl: '/badges/early-bird.png',
        criteria: {
            type: 'xp',
            target: 1
        },
        category: 'special',
        displayOrder: 100,
        xpBonus: 50,
        isActive: false // This will be manually awarded
    }
];

/**
 * Seed badges to database
 */
const seedBadges = async () => {
    try {
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('✅ Connected to MongoDB');
        
        // Clear existing badges (optional - comment out if you want to keep existing)
        await Badge.deleteMany({});
        console.log('🗑️  Cleared existing badges');
        
        // Insert new badges
        const result = await Badge.insertMany(badges);
        console.log(`✅ Successfully seeded ${result.length} badges`);
        
        // Display summary by category
        const categories = ['bronze', 'silver', 'gold', 'platinum', 'special'];
        console.log('\n📊 Badges by category:');
        for (const category of categories) {
            const count = result.filter(b => b.category === category).length;
            console.log(`   ${category.toUpperCase()}: ${count}`);
        }
        
        // Display summary by type
        const types = ['xp', 'words_learned', 'streak', 'lessons_completed', 'perfect_scores', 'level', 'daily_goal'];
        console.log('\n📊 Badges by criteria type:');
        for (const type of types) {
            const count = result.filter(b => b.criteria.type === type).length;
            if (count > 0) {
                console.log(`   ${type}: ${count}`);
            }
        }
        
        console.log('\n✨ Badge seeding completed successfully!');
        
    } catch (error) {
        console.error('❌ Error seeding badges:', error);
        throw error;
    } finally {
        // Close connection
        await mongoose.connection.close();
        console.log('🔌 Database connection closed');
    }
};

// Run the seed function
if (require.main === module) {
    seedBadges()
        .then(() => {
            console.log('👋 Seed script finished');
            process.exit(0);
        })
        .catch((error) => {
            console.error('💥 Seed script failed:', error);
            process.exit(1);
        });
}

module.exports = { seedBadges, badges };
