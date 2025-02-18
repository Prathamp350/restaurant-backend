const mongoose = require('mongoose');

const menuItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  price: { type: Number, required: true },
  category: { type: String, required: true }
});  // Optional: Adds `createdAt` and `updatedAt` fields

const MenuItem = mongoose.model('MenuItem', menuItemSchema);

module.exports = MenuItem;
