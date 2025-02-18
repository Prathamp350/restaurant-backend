const mongoose = require('mongoose');

// Define the schema for the Report model
const reportSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  generatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // Assuming 'User' model represents the user generating the report
    required: true,
  },
  generatedAt: {
    type: Date,
    default: Date.now, // Automatically set the report creation date
  },
  status: {
    type: String,
    enum: ['draft', 'finalized'], // The status of the report
    default: 'draft',
  },
});

// Create the Report model based on the schema
const Report = mongoose.model('Report', reportSchema);

module.exports = Report;
