path = require('path');

module.exports = {
  root: path.resolve('./'),
  paths: {
    constructors: path.resolve('./app/constructors'),
    serializers: path.resolve('./app/serializers'),
    uploads: './public/uploads',
    models: path.resolve('./app/models'),
    public: path.resolve('./public'),
    utils: path.resolve('./app/utils'),
    app: path.resolve('./app')
  },
  app: {
    name: 'college-project-backend-express'
  },
  db: 'mongodb://localhost/college-project-backend-express-development',
  port: 3000
};