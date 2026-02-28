import { useState, useEffect } from "react";

function App() {

  // incoming emergencies from database
  const [requests, setRequests] = useState([]);

  // accepted patients (hospital preparing)
  const [acceptedPatients, setAcceptedPatients] = useState([]);

  /* ---------------------------------------------------
     This is the IMPORTANT PART
     Backend (Supabase) will call this function later
     Example:
     window.addEmergency(newRowFromDatabase)
  ----------------------------------------------------*/
  useEffect(() => {
    window.addEmergency = (data) => {
      setRequests(prev => [data, ...prev]);
    };
  }, []);

  // ACCEPT
  function acceptRequest(id) {
    const selected = requests.find(req => req.id === id);
    if (!selected) return;

    setAcceptedPatients(prev => [selected, ...prev]);
    setRequests(prev => prev.filter(req => req.id !== id));

    // later: this is where database update will go
    console.log("ACCEPTED:", id);
  }

  // REJECT
  function rejectRequest(id) {
    setRequests(prev => prev.filter(req => req.id !== id));

    // later: database update here
    console.log("REJECTED:", id);
  }

  return (
    <div style={{ background: "#eef3f8", minHeight: "100vh", fontFamily: "Arial" }}>

      {/* HEADER */}
      <div style={{
        backgroundColor: "#3172e3",
        color: "white",
        padding: "18px 30px",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center"
      }}>
        <h2>HC005 Emergency Coordination — Hospital Panel</h2>
      </div>

      {/* DASHBOARD */}
      <div style={{
        display: "flex",
        gap: "25px",
        padding: "25px",
        alignItems: "flex-start"
      }}>

        {/* LEFT PANEL — INCOMING REQUESTS */}
        <div style={{
          flex: 1,
          background: "#f8fbff",
          padding: "20px",
          borderRadius: "12px",
          minHeight: "80vh",
          boxShadow: "0 4px 14px rgba(0,0,0,0.08)"
        }}>

          <h2 style={{ color: "#b30000" }}>Incoming Emergency Requests</h2>

          {requests.length === 0 && (
            <h3 style={{ color: "#666" }}>
              Waiting for incoming emergency...
            </h3>
          )}

          {requests.map((req) => {

            let severityColor = "#ff6600";
            if (req.severity === "CRITICAL") severityColor = "#b30000";

            return (
              <div
                key={req.id}
                style={{
                  background: "white",
                  padding: "18px",
                  marginTop: "15px",
                  borderRadius: "10px",
                  boxShadow: "0 5px 14px rgba(0,0,0,0.12)",
                  borderLeft: `8px solid ${severityColor}`
                }}
              >
                <h3>Incoming Emergency</h3>

                <p><b>Patient:</b> {req.patient}</p>
                <p><b>Required Care:</b> {req.caretype}</p>
                <p><b>Location:</b> {req.location}</p>
                <p><b>Ambulance ETA:</b> {req.eta} minutes</p>
                <p>
                  <b>Severity:</b>{" "}
                  <span style={{ color: severityColor, fontWeight: "bold" }}>
                    {req.severity}
                  </span>
                </p>

                <div style={{ marginTop: "12px" }}>
                  <button
                    onClick={() => acceptRequest(req.id)}
                    style={{
                      background: "#1a7f37",
                      color: "white",
                      padding: "10px 18px",
                      marginRight: "10px",
                      border: "none",
                      borderRadius: "8px",
                      cursor: "pointer",
                      fontWeight: "bold"
                    }}
                  >
                    ACCEPT
                  </button>

                  <button
                    onClick={() => rejectRequest(req.id)}
                    style={{
                      background: "#d11a2a",
                      color: "white",
                      padding: "10px 18px",
                      border: "none",
                      borderRadius: "8px",
                      cursor: "pointer",
                      fontWeight: "bold"
                    }}
                  >
                    REJECT
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        {/* RIGHT PANEL — ACCEPTED PATIENTS */}
        <div style={{
          flex: 1,
          background: "#f4fff6",
          padding: "20px",
          borderRadius: "12px",
          minHeight: "80vh",
          boxShadow: "0 4px 14px rgba(0,0,0,0.08)"
        }}>

          <h2 style={{ color: "#0b3d91" }}>Preparing For Arrival</h2>

          {acceptedPatients.length === 0 && (
            <h3 style={{ color: "#666" }}>
              No patients accepted yet
            </h3>
          )}

          {acceptedPatients.map((req) => (
            <div
              key={req.id}
              style={{
                background: "white",
                padding: "18px",
                marginTop: "15px",
                borderRadius: "10px",
                boxShadow: "0 5px 14px rgba(0,0,0,0.12)",
                borderLeft: "8px solid #1a7f37"
              }}
            >
              <h3>🩺 Accepted Patient</h3>

              <p><b>Patient:</b> {req.patient}</p>
              <p><b>Required Care:</b> {req.caretype}</p>
              <p><b>Location:</b> {req.location}</p>
              <p><b>ETA:</b> {req.eta} minutes</p>
              <p><b>Status:</b> Preparing Emergency Unit</p>
            </div>
          ))}
        </div>

      </div>
    </div>
  );
}

export default App;