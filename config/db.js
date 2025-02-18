const { Sequelize } = require('sequelize');

// Create a new Sequelize instance
const sequelize = new Sequelize('restaurant_db', 'root', '', {
    host: 'localhost',
    dialect: 'mysql',
});

module.exports = { sequelize };
