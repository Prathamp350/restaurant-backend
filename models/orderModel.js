const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  tableOrGuest: { type: String, required: true },
  items: [
    {
      menuItemId: { type: mongoose.Schema.Types.ObjectId, ref: 'MenuItem', required: true },
      quantity: { type: Number, required: true },
    },
  ],
  status: { type: String, required: true, enum: ['Pending', 'Completed', 'Cancelled'] },
  totalPrice: { type: Number, required: true },
}, { timestamps: true });

const Order = mongoose.model('Order', OrderSchema);

module.exports = Order;
