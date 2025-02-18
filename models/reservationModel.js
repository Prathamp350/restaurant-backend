// models/reservationModel.js
const mongoose = require('mongoose');

const reservationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  mobile: { type: String, required: true },
  date: { type: String, required: true },
  time: { type: String, required: true },
  guests: { type: Number, required: true },
  specialRequest: { type: String },
  status: { type: String, default: "Pending" }, // New field with default value
});


module.exports = mongoose.model('Reservation', reservationSchema);
