/**
 * Middleware to track and log slow API requests
 * Helps identify performance bottlenecks
 */

const SLOW_REQUEST_THRESHOLD_MS = parseInt(process.env.SLOW_REQUEST_THRESHOLD_MS) || 500;

/**
 * Performance monitoring middleware
 */
function performanceMonitor(req, res, next) {
  const startTime = Date.now();
  
  // Store original end function
  const originalEnd = res.end;
  
  // Override end function to log performance
  res.end = function(...args) {
    const duration = Date.now() - startTime;
    
    // Log slow requests
    if (duration > SLOW_REQUEST_THRESHOLD_MS) {
      console.warn(`⚠️ SLOW REQUEST: ${req.method} ${req.originalUrl} - ${duration}ms - Status: ${res.statusCode}`);
      
      // Log additional details for very slow requests (> 1s)
      if (duration > 1000) {
        console.warn(`  ⏱️ Request details:`, {
          method: req.method,
          url: req.originalUrl,
          duration: `${duration}ms`,
          statusCode: res.statusCode,
          userAgent: req.get('user-agent'),
          ip: req.ip || req.connection.remoteAddress,
        });
      }
    } else if (process.env.NODE_ENV === 'development' && duration > 100) {
      // Log normal requests in development mode
      console.log(`✅ ${req.method} ${req.originalUrl} - ${duration}ms`);
    }
    
    // Call original end function
    originalEnd.apply(res, args);
  };
  
  next();
}

/**
 * Database query performance monitoring
 * Can be used with mongoose hooks
 */
function setupMongooseQueryMonitoring(mongoose) {
  if (process.env.ENABLE_QUERY_LOGGING === 'true') {
    mongoose.set('debug', (collectionName, method, query, doc, options) => {
      console.log(`🔍 MongoDB Query: ${collectionName}.${method}`, {
        query: JSON.stringify(query),
        options: JSON.stringify(options),
      });
    });
  }
}

module.exports = {
  performanceMonitor,
  setupMongooseQueryMonitoring,
  SLOW_REQUEST_THRESHOLD_MS,
};
