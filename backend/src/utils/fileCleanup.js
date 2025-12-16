const fs = require('fs/promises');
const path = require('path');

/**
 * Cleanup old files in a directory
 * @param {string} dirPath - Directory path to clean
 * @param {number} maxAgeHours - Maximum age in hours (default: 24 hours)
 * @param {Array<string>} extensions - File extensions to clean (e.g., ['.mp3', '.wav'])
 */
async function cleanupOldFiles(dirPath, maxAgeHours = 24, extensions = []) {
  try {
    const now = Date.now();
    const maxAgeMs = maxAgeHours * 60 * 60 * 1000;
    
    const files = await fs.readdir(dirPath);
    let deletedCount = 0;
    let totalSize = 0;
    
    for (const file of files) {
      const filePath = path.join(dirPath, file);
      
      try {
        const stats = await fs.stat(filePath);
        
        // Skip directories
        if (stats.isDirectory()) {
          continue;
        }
        
        // Check file extension filter
        if (extensions.length > 0) {
          const ext = path.extname(file).toLowerCase();
          if (!extensions.includes(ext)) {
            continue;
          }
        }
        
        // Check file age
        const fileAge = now - stats.mtimeMs;
        if (fileAge > maxAgeMs) {
          await fs.unlink(filePath);
          deletedCount++;
          totalSize += stats.size;
          console.log(`🗑️ Deleted old file: ${file} (${(stats.size / 1024).toFixed(2)} KB, age: ${(fileAge / 3600000).toFixed(1)}h)`);
        }
      } catch (err) {
        console.error(`❌ Error processing file ${file}:`, err.message);
      }
    }
    
    if (deletedCount > 0) {
      console.log(`✅ Cleanup completed: ${deletedCount} files deleted, ${(totalSize / 1024 / 1024).toFixed(2)} MB freed`);
    }
    
    return { deletedCount, totalSize };
  } catch (error) {
    console.error('❌ Error in cleanupOldFiles:', error);
    throw error;
  }
}

/**
 * Cleanup audio uploads directory
 * Removes audio files older than specified hours
 */
async function cleanupAudioUploads(maxAgeHours = 24) {
  const audioDir = path.join(__dirname, '../../uploads/audio');
  const audioExtensions = ['.mp3', '.wav', '.webm', '.ogg', '.m4a', '.aac'];
  
  console.log(`🧹 Starting audio cleanup (files older than ${maxAgeHours}h)...`);
  return await cleanupOldFiles(audioDir, maxAgeHours, audioExtensions);
}

/**
 * Schedule periodic cleanup
 * @param {number} intervalHours - Interval in hours (default: 6 hours)
 * @param {number} maxFileAgeHours - Max file age to keep (default: 24 hours)
 */
function scheduleCleanup(intervalHours = 6, maxFileAgeHours = 24) {
  const intervalMs = intervalHours * 60 * 60 * 1000;
  
  console.log(`📅 Scheduled file cleanup every ${intervalHours} hours (keeping files < ${maxFileAgeHours}h old)`);
  
  // Run immediately on startup
  cleanupAudioUploads(maxFileAgeHours).catch(err => 
    console.error('Initial cleanup failed:', err)
  );
  
  // Then run periodically
  return setInterval(() => {
    cleanupAudioUploads(maxFileAgeHours).catch(err => 
      console.error('Scheduled cleanup failed:', err)
    );
  }, intervalMs);
}

module.exports = {
  cleanupOldFiles,
  cleanupAudioUploads,
  scheduleCleanup,
};
