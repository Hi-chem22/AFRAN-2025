const dns = require('dns');
const net = require('net');
const { exec } = require('child_process');

// MongoDB Atlas hostnames to check
const hosts = [
  'cluster0.pt98b.mongodb.net',
  'cluster0-shard-00-00.pt98b.mongodb.net',
  'cluster0-shard-00-01.pt98b.mongodb.net',
  'cluster0-shard-00-02.pt98b.mongodb.net'
];

// MongoDB Atlas ports to check
const mongoDbPorts = [27017, 27018, 27019];

// Function to check DNS resolution
function checkDns(hostname) {
  return new Promise((resolve) => {
    dns.lookup(hostname, (err, address) => {
      if (err) {
        console.log(`❌ DNS lookup failed for ${hostname}: ${err.code}`);
        resolve(false);
      } else {
        console.log(`✅ DNS lookup successful for ${hostname}: ${address}`);
        resolve(true);
      }
    });
  });
}

// Function to check SRV records
function checkSrv(hostname) {
  return new Promise((resolve) => {
    dns.resolveSrv(`_mongodb._tcp.${hostname}`, (err, addresses) => {
      if (err) {
        console.log(`❌ SRV lookup failed for _mongodb._tcp.${hostname}: ${err.code}`);
        resolve(false);
      } else {
        console.log(`✅ SRV lookup successful for _mongodb._tcp.${hostname}:`);
        addresses.forEach(addr => {
          console.log(`   - ${addr.name}:${addr.port} (priority: ${addr.priority})`);
        });
        resolve(true);
      }
    });
  });
}

// Function to check TCP connection
function checkTcpConnection(host, port) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    let connected = false;
    
    // Set timeout to 5 seconds
    socket.setTimeout(5000);
    
    socket.on('connect', () => {
      connected = true;
      console.log(`✅ TCP connection successful to ${host}:${port}`);
      socket.end();
    });
    
    socket.on('timeout', () => {
      console.log(`❌ Connection timeout for ${host}:${port}`);
      socket.destroy();
      resolve(false);
    });
    
    socket.on('error', (err) => {
      console.log(`❌ TCP connection failed to ${host}:${port}: ${err.message}`);
      resolve(false);
    });
    
    socket.on('close', () => {
      resolve(connected);
    });
    
    socket.connect(port, host);
  });
}

// Function to ping a host
function pingHost(hostname) {
  return new Promise((resolve) => {
    // Use different ping command based on OS
    const pingCmd = process.platform === 'win32' 
      ? `ping -n 3 ${hostname}` 
      : `ping -c 3 ${hostname}`;
    
    exec(pingCmd, (err, stdout, stderr) => {
      if (err) {
        console.log(`❌ Ping failed for ${hostname}`);
        resolve(false);
      } else {
        console.log(`✅ Ping successful for ${hostname}`);
        resolve(true);
      }
    });
  });
}

// Main function to run all checks
async function runConnectivityChecks() {
  console.log("=================================================");
  console.log("MONGODB ATLAS CONNECTIVITY DIAGNOSTIC");
  console.log("=================================================");
  
  console.log("\n--- Checking DNS Resolution ---");
  for (const host of hosts) {
    await checkDns(host);
  }
  
  console.log("\n--- Checking SRV Records ---");
  await checkSrv(hosts[0]); // Only check SRV for the main host
  
  console.log("\n--- Checking TCP Connectivity ---");
  for (const host of hosts.slice(1)) { // Skip the main host for TCP checks
    for (const port of mongoDbPorts) {
      await checkTcpConnection(host, port);
    }
  }
  
  console.log("\n--- Ping Tests ---");
  for (const host of hosts) {
    await pingHost(host);
  }
  
  console.log("\n=================================================");
  console.log("IMPORTANT NOTES:");
  console.log("1. If DNS lookups fail, you may have DNS resolution issues");
  console.log("2. If TCP connections fail but DNS works, there may be a firewall blocking access");
  console.log("3. If all tests pass but MongoDB connection still fails, the issue is likely with authentication");
  console.log("=================================================");
}

// Run the checks
runConnectivityChecks().catch(console.error); 