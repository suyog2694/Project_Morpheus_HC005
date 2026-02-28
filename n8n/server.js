console.log("=== THIS IS THE ACTIVE SERVER FILE ===");
console.log("File path:", __filename);
require('dotenv').config();
const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(express.json());

// ============================
// 🔐 Supabase Setup
// ============================
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// ============================
// 🔎 Health Check Route
// ============================
app.get('/ping', (req, res) => {
  res.send('Server is alive');
});

// ============================
// 🔵 Update Availability
// ============================
app.post('/api/update-availability', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || authHeader !== `Bearer ${process.env.API_SECRET}`) {
      return res.status(401).json({ error: 'Unauthorized access' });
    }

    const {
      hospital_id,
      icu,
      general_beds,
      ventilators,
      last_updated
    } = req.body;

    if (!hospital_id || icu == null || general_beds == null || ventilators == null) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (icu < 0 || general_beds < 0 || ventilators < 0) {
      return res.status(400).json({ error: 'Values cannot be negative' });
    }

    // Update live availability
    const { data, error } = await supabase
      .from('hospital_resources')
      .update({
        icu_available: icu,
        bed_available: general_beds,
        ventilator_available: ventilators,
        last_updated_at: last_updated || new Date().toISOString()
      })
      .eq('hospital_id', hospital_id)
      .select();

    if (error) {
      console.error(error);
      return res.status(500).json({ error: 'Database update failed' });
    }

    if (!data || data.length === 0) {
      return res.status(404).json({ error: 'Hospital not found' });
    }

    // Insert into history
    await supabase
      .from('hospital_resource_history')
      .insert([
        {
          hospital_id,
          icu_available: icu,
          bed_available: general_beds,
          ventilator_available: ventilators
        }
      ]);

    return res.status(200).json({
      message: 'Availability updated and history logged',
      hospital_id
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================
// 📈 Get Last 3 History Entries
// ============================
app.get('/api/hospital-history/:id', async (req, res) => {
  try {
    const hospital_id = parseInt(req.params.id);

    const { data, error } = await supabase
      .from('hospital_resource_history')
      .select('icu_available, recorded_at')
      .eq('hospital_id', hospital_id)
      .order('recorded_at', { ascending: false })
      .limit(3);

    if (error) {
      console.error(error);
      return res.status(500).json({ error: 'Failed to fetch history' });
    }

    return res.status(200).json(data);

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// ============================
// 🚀 Start Server
// ============================
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});