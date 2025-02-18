const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const User = require('./models/userModel');
const Reservation = require('./models/reservationModel');
const Report = require('./models/reportModel'); // Assuming a report model exists
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const MenuItem = require('./models/menuitemModel');
const Order = require('./models/orderModel');




const app = express();
app.use(cors());
app.use(express.json());

// Database Connection
mongoose.connect('mongodb://localhost:27017/restaurant', )
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('Could not connect to MongoDB:', err);
    process.exit(1);
  });

// Secret Key
const JWT_SECRET = 'yourSecretKey';

// Routes

// Authentication Routes
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });
    if (!user) return res.status(404).json({ message: 'User does not exist' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid password' });

    const token = jwt.sign({ userId: user._id, role: user.role }, JWT_SECRET);
    res.json({ success: true, role: user.role, token });
  } catch (err) {
    console.error('Error during login:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

app.post('/register', async (req, res) => {
  const { username, password, role } = req.body;

  if (!username || !password || !role) return res.status(400).json({ message: 'All fields are required' });

  try {
    const existingUser = await User.findOne({ username });
    if (existingUser) return res.status(400).json({ message: 'User already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ username, password: hashedPassword, role });

    await user.save();
    res.status(201).json({ success: true, message: 'User registered successfully' });
  } catch (err) {
    console.error('Error during registration:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

// Reservation Routes
app.post('/api/reservations', async (req, res) => {
  const { name, mobile, date, time, guests, specialRequest } = req.body;

  if (!name || !mobile || !date || !time || !guests) return res.status(400).json({ message: 'Missing required fields' });

  try {
    const newReservation = new Reservation({ name, mobile, date, time, guests, specialRequest });
    await newReservation.save();
    res.status(201).json({ message: 'Reservation created successfully!' });
  } catch (error) {
    console.error('Error saving reservation:', error);
    res.status(500).json({ message: 'Failed to create reservation' });
  }
});

app.get('/api/reservations', async (req, res) => {
  const { status } = req.query;

  try {
    const query = status ? { status } : {};
    const reservations = await Reservation.find(query);
    res.json(reservations);
  } catch (error) {
    console.error('Error fetching reservations:', error);
    res.status(500).json({ message: 'Error fetching reservations' });
  }
});

app.put('/api/reservations/:id', async (req, res) => {
  const { status } = req.body;

  try {
    const updatedReservation = await Reservation.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!updatedReservation) return res.status(404).json({ message: 'Reservation not found' });

    res.json(updatedReservation);
  } catch (error) {
    console.error('Error updating reservation status:', error);
    res.status(500).json({ message: 'Error updating reservation status' });
  }
});

app.delete('/api/reservations/:id', async (req, res) => {
  try {
    const deletedReservation = await Reservation.findByIdAndDelete(req.params.id);
    if (!deletedReservation) return res.status(404).json({ message: 'Reservation not found' });

    res.json({ message: 'Reservation deleted successfully' });
  } catch (error) {
    console.error('Error deleting reservation:', error);
    res.status(500).json({ message: 'Error deleting reservation' });
  }
});

// User Management (Admin Only)
app.get('/api/users', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching users' });
  }
});

app.post('/api/users', async (req, res) => {
  const { username, password, role } = req.body;

  if (!username || !password || !role) return res.status(400).json({ message: 'All fields are required' });

  try {
    const existingUser = await User.findOne({ username });
    if (existingUser) return res.status(400).json({ message: 'User already exists' });

    // Remove manual hashing here
    const user = new User({ username, password, role }); // Don't hash the password manually

    await user.save();
    res.status(201).json({ success: true, message: 'User created successfully', user });

  } catch (err) {
    console.error('Error creating user:', err);
    res.status(500).json({ message: 'Error creating user' });
  }
});


app.put('/api/users/:id', async (req, res) => {
  const { username, password, role } = req.body;

  try {
    const updates = { username, role };
    if (password) updates.password = await bcrypt.hash(password, 10);

    const updatedUser = await User.findByIdAndUpdate(req.params.id, updates, { new: true });
    res.json(updatedUser);
  } catch (err) {
    console.error('Error updating user:', err);
    res.status(500).json({ message: 'Error updating user' });
  }
});

app.delete('/api/users/:id', async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (err) {
    console.error('Error deleting user:', err);
    res.status(500).json({ message: 'Error deleting user' });
  }
});

// Stats Route
app.get('/api/stats', async (req, res) => {
  try {
    const activeUsers = await User.countDocuments();
    const pendingReservations = await Reservation.countDocuments();
    const reportsGenerated = await Report.countDocuments();

    res.json({ activeUsers, pendingReservations, reportsGenerated });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ message: 'Error fetching stats' });
  }
});

app.post('/api/menus', async (req, res) => {
  try {
    const { name, description, price, category } = req.body;

    // Log the incoming data to make sure it's correct
    console.log('Menu Item Data:', { name, description, price, category });

    // Check if any of the fields are missing
    if (!name || !price || !category) {
      return res.status(400).json({ success: false, message: 'All fields are required.' });
    }

    // Create a new menu item
    const newItem = new MenuItem({ name, description, price, category });

    // Log before saving to check data
    console.log('New Item Before Save:', newItem);

    // Save the item to the database
    await newItem.save();

    // Log the saved item to confirm it's stored
    console.log('Saved Item:', newItem);

    res.status(201).json({ success: true, message: "Menu item added successfully", data: newItem });
  } catch (error) {
    console.error("Error adding menu item:", error);
    res.status(500).json({ success: false, message: "Error adding menu item", error });
  }
});

app.put('/api/menus/:id', async (req, res) => {
  try {
    const { name, description, price, category } = req.body;
    const updatedItem = await MenuItem.findByIdAndUpdate(req.params.id, { name, description, price, category }, { new: true });
    if (!updatedItem) return res.status(404).json({ success: false, message: "Item not found" });
    res.status(200).json({ success: true, message: "Menu item updated successfully", data: updatedItem });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error updating menu item", error });
  }
});

app.get('/api/menus', async (req, res) => {
  try {
    // Fetch all menu items from the database
    const menuItems = await MenuItem.find(); // This retrieves all items from the 'menuItems' collection

    // Send the fetched menu items as a JSON response
    res.status(200).json(menuItems); 
  } catch (error) {
    // If there is an error, send a 500 status with an error message
    console.error('Error fetching menu items:', error);
    res.status(500).json({ error: 'Failed to fetch menu items' });
  }
});

// Create a new order
app.post('/api/orders', async (req, res) => {
  const { customerName, items, totalAmount, orderType } = req.body;

  if (!customerName || !items || !totalAmount || !orderType) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const newOrder = new Order({ customerName, items, totalAmount, orderType });
    await newOrder.save();
    res.status(201).json({ message: 'Order created successfully!', order: newOrder });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ message: 'Failed to create order' });
  }
});

// Fetch all orders
app.get('/api/orders', async (req, res) => {
  try {
    const orders = await Order.find().populate('items'); // Populate menu items
    res.json(orders);
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({ message: 'Error fetching orders' });
  }
});

// Update an order (e.g., mark as completed, canceled)
app.put('/api/orders/:id', async (req, res) => {
  const { status } = req.body;

  try {
    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!updatedOrder) return res.status(404).json({ message: 'Order not found' });

    res.json(updatedOrder);
  } catch (error) {
    console.error('Error updating order status:', error);
    res.status(500).json({ message: 'Error updating order status' });
  }
});

// Delete an order
app.delete('/api/orders/:id', async (req, res) => {
  try {
    const deletedOrder = await Order.findByIdAndDelete(req.params.id);
    if (!deletedOrder) return res.status(404).json({ message: 'Order not found' });

    res.json({ message: 'Order deleted successfully' });
  } catch (error) {
    console.error('Error deleting order:', error);
    res.status(500).json({ message: 'Error deleting order' });
  }
});

// Start the Server
app.listen(5000, () => console.log('Server is running on http://localhost:5000'));