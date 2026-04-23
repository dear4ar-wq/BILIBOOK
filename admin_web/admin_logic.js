// BikiBook Web Admin Logic - Pro Version (Synced, Notifications & PDF)
const SUPABASE_URL = 'https://xkyhuboqxtrgflmumczu.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhreWh1Ym9xeHRyZ2ZsbXVtY3p1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MDYxNTQsImV4cCI6MjA5MjE4MjE1NH0.ekStgsHpUPmagb_D5og_EGfI2BHBui5q8XZ4wAkzczc';

const _supabase = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// Auth State Listener
_supabase.auth.onAuthStateChange(async (event, session) => {
    if (session) verifyAdmin(session.user);
});

async function verifyAdmin(user) {
    if (user.email === 'sagardeepmix@gmail.com' || user.id === '443f60ef-565f-44ef-b63b-9c34d23049c2') {
        document.getElementById('login-overlay').style.display = 'none';
        document.getElementById('admin-email').innerText = user.email;
        initDashboard();
        return;
    }
    const { data } = await _supabase.from('users').select('is_admin').eq('id', user.id).single();
    if (data?.is_admin) {
        document.getElementById('login-overlay').style.display = 'none';
        document.getElementById('admin-email').innerText = user.email;
        initDashboard();
    } else {
        alert("Access Denied");
        await _supabase.auth.signOut();
    }
}

function switchTab(tab) {
    const sections = ['dashboard-section', 'prizes-section', 'users-section', 'withdrawals-section'];
    sections.forEach(s => {
        const el = document.getElementById(s);
        if (el) el.style.display = s.startsWith(tab) ? 'block' : 'none';
    });

    if (tab === 'dashboard') initDashboard();
    if (tab === 'prizes') loadPrizeTickets();
    if (tab === 'withdrawals') loadWithdrawals();
}

function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

// DASHBOARD
async function initDashboard() {
    try {
        const { count: drawCount } = await _supabase.from('draws').select('*', { count: 'exact', head: true });
        const { count: bookingCount } = await _supabase.from('tickets').select('*', { count: 'exact', head: true });
        const { count: pendingCount } = await _supabase.from('tickets').select('*', { count: 'exact', head: true }).eq('status', 'pending');
        const { count: userCount } = await _supabase.from('users').select('*', { count: 'exact', head: true });
        document.getElementById('stat-active-draws').innerText = drawCount || 0;
        document.getElementById('stat-total-bookings').innerText = bookingCount || 0;
        document.getElementById('stat-pending-bookings').innerText = pendingCount || 0;
        document.getElementById('stat-total-users').innerText = userCount || 0;
        loadRecentBookings();
    } catch (e) {}
}

// PDF UPLOAD LOGIC
function openPDFModal(id, name) {
    document.getElementById('pdf-draw-id').value = id;
    document.getElementById('pdf-draw-name').innerText = "Result PDF for: " + name;
    document.getElementById('pdf-status').innerText = "";
    openModal('pdfModal');
}

async function uploadPDF() {
    const draw_id = document.getElementById('pdf-draw-id').value;
    const file = document.getElementById('pdfFile').files[0];
    const statusEl = document.getElementById('pdf-status');

    if (!file) return alert("Select a PDF file first");
    
    statusEl.innerText = "Uploading... please wait.";
    
    const fileName = `results/${draw_id}_${Date.now()}.pdf`;
    
    // 1. Upload to Supabase Storage (Bucket: 'results')
    const { data: uploadData, error: uploadError } = await _supabase.storage
        .from('results')
        .upload(fileName, file);

    if (uploadError) {
        statusEl.innerText = "Upload failed. Make sure 'results' bucket is Public.";
        return alert(uploadError.message);
    }

    // 2. Get Public URL
    const { data: { publicUrl } } = _supabase.storage.from('results').getPublicUrl(fileName);

    // 3. Update Draws table
    const { error: updateError } = await _supabase.from('draws').update({ pdf_url: publicUrl }).eq('id', draw_id);

    if (updateError) alert(updateError.message);
    else {
        alert("Official PDF Result Uploaded Successfully!");
        closeModal('pdfModal');
        loadDraws();
    }
}

// DRAWS & TICKETS
async function loadDraws() {
    const { data } = await _supabase.from('draws').select('*').order('draw_date', { ascending: false });
    if (data) {
        document.getElementById('draws-table').innerHTML = data.map(d => `
            <tr>
                <td>${d.name}</td>
                <td>${new Date(d.draw_date).toLocaleString()}</td>
                <td>₹${d.ticket_price}</td>
                <td><strong>${d.result || 'PENDING'}</strong></td>
                <td>
                    <button class="btn btn-primary" onclick="openTicketUpload('${d.id}', '${d.name}')" title="Upload Tickets"><i class="fas fa-upload"></i></button>
                    <button class="btn" style="background:#0984e3; color:white;" onclick="openPDFModal('${d.id}', '${d.name}')" title="Upload PDF">
                        <i class="fas ${d.pdf_url ? 'fa-file-pdf' : 'fa-file-upload'}"></i>
                    </button>
                    <button class="btn btn-accent" onclick="openResultModal('${d.id}')" title="Publish Result"><i class="fas fa-trophy"></i></button>
                    <button class="btn" style="background:#ff7675;color:white;" onclick="deleteDraw('${d.id}')"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');
    }
}

async function quickAddDraw(type) {
    const now = new Date();
    let drawTime = new Date();
    if (type.includes('1PM')) drawTime.setHours(13, 0, 0, 0);
    else if (type.includes('6PM')) drawTime.setHours(18, 0, 0, 0);
    else if (type.includes('8PM')) drawTime.setHours(20, 0, 0, 0);
    if (drawTime < now) drawTime.setDate(drawTime.getDate() + 1);
    await _supabase.from('draws').insert([{ name: type, draw_date: drawTime.toISOString(), ticket_price: 6 }]);
    loadDraws();
}

async function saveDraw() {
    const name = document.getElementById('drawName').value;
    const date = document.getElementById('drawDate').value;
    const price = document.getElementById('drawPrice').value;
    
    if(!name || !date) return alert("Please fill all fields");

    const { error } = await _supabase.from('draws').insert([{ 
        name, 
        draw_date: new Date(date).toISOString(), 
        ticket_price: parseInt(price) 
    }]);

    if(error) alert(error.message);
    else {
        alert("Draw Saved Successfully!");
        closeModal('drawModal');
        loadDraws();
    }
}

async function deleteDraw(id) {
    if(!confirm("Are you sure you want to delete this draw? ALL linked tickets will also be deleted.")) return;
    
    const { error } = await _supabase.from('draws').delete().eq('id', id);
    if(error) alert(error.message);
    else {
        alert("Draw Deleted Successfully");
        loadDraws();
    }
}

function updateAdminCheckout() {
    const sem = parseInt(document.getElementById('admin-ticket-sem').value) || 5;
    const series = parseInt(document.getElementById('admin-series-count').value) || 1;
    const total = sem * 7 * series;
    document.getElementById('admin-total-cost').innerText = "₹" + total;
}

// Initial update when modal opens
function openTicketUpload(id, name) {
    document.getElementById('target-draw-id').value = id;
    document.getElementById('target-draw-name').innerText = "Sync for: " + name;
    
    // Reset values to defaults
    document.getElementById('admin-ticket-sem').value = "5";
    document.getElementById('admin-series-count').value = "1";
    document.getElementById('ticketList').value = "";
    
    updateAdminCheckout();
    openModal('ticketModal');
}

async function processTicketUpload() {
    const draw_id = document.getElementById('target-draw-id').value;
    const sem = document.getElementById('admin-ticket-sem').value;
    const series = document.getElementById('admin-series-count').value;
    const tokens = document.getElementById('ticketList').value.split('\n').map(t => t.trim()).filter(t => t.length > 0);
    
    if (tokens.length === 0) return alert("Please enter at least one ticket number");

    const { error } = await _supabase.from('tickets').insert(tokens.map(t => ({ 
        draw_id, 
        ticket_number: t, 
        status: 'active',
        sem_count: parseInt(sem),
        series_count: parseInt(series)
    })));

    if(!error) { 
        alert(`Sync Completed: ${tokens.length} tickets added.`); 
        closeModal('ticketModal'); 
        initDashboard();
    } else {
        alert("Error: " + error.message);
    }
}

async function publishResult() {
    const id = document.getElementById('result-draw-id').value;
    const result = document.getElementById('winningNumber').value;
    await _supabase.from('draws').update({ result }).eq('id', id);
    await _supabase.from('tickets').update({ status: 'won' }).eq('draw_id', id).eq('ticket_number', result);
    await _supabase.from('tickets').update({ status: 'lost' }).eq('draw_id', id).neq('ticket_number', result).eq('status', 'active');
    alert("App Updated with Result"); closeModal('resultModal'); loadDraws();
}

// OTHER HANDLERS
async function loadAllBookings() { const { data } = await _supabase.from('tickets').select('*, draws(name), users(phone_number)').order('created_at', { ascending: false }); if(data) document.getElementById('all-bookings-table').innerHTML = data.map(t => `<tr><td>${t.ticket_number}</td><td>${t.draws?.name}</td><td>${t.users?.phone_number}</td><td>${t.status.toUpperCase()}</td><td><button class="btn" onclick="updateStatus('${t.id}', 'active')">OK</button></td></tr>`).join(''); }
async function updateStatus(id, s) { await _supabase.from('tickets').update({ status: s }).eq('id', id); loadAllBookings(); }
async function loadAllUsers() { const { data } = await _supabase.from('users').select('*'); if(data) document.getElementById('all-users-table').innerHTML = data.map(u => `<tr><td>${u.phone_number}</td><td>${u.is_admin ? 'Admin' : 'User'}</td><td><button class="btn" onclick="toggleAdmin('${u.id}', ${!u.is_admin})">Role</button></td></tr>`).join(''); }
async function toggleAdmin(id, s) { await _supabase.from('users').update({ is_admin: s }).eq('id', id); loadAllUsers(); }
async function loadAllPayments() { const { data } = await _supabase.from('payments').select('*, users(phone_number)'); if(data) document.getElementById('all-payments-table').innerHTML = data.map(p => `<tr><td>#${p.id.substring(0,6)}</td><td>${p.users?.phone_number}</td><td>₹${p.amount}</td><td>${p.status}</td><td><button class="btn" onclick="updatePay('${p.id}', 'success')">OK</button></td></tr>`).join(''); }
async function updatePay(id, s) { await _supabase.from('payments').update({ status: s }).eq('id', id); loadAllPayments(); }

async function loadPrizes() {
    const tableBody = document.getElementById('all-prizes-table');
    tableBody.innerHTML = '<tr><td colspan="6" style="text-align:center;">Loading Prize Tickets...</td></tr>';
    
    const { data, error } = await _supabase.from('prize_tickets').select('*, users(phone_number)').order('created_at', { ascending: false });
    
    if (error) {
        console.error("Supabase Error:", error);
        tableBody.innerHTML = `<tr><td colspan="6" style="text-align:center; color:red;">Error loading: ${error.message}</td></tr>`;
        return;
    }
    
    if (!data || data.length === 0) {
        tableBody.innerHTML = '<tr><td colspan="6" style="text-align:center;">No tickets uploaded by users yet.</td></tr>';
        return;
    }

    tableBody.innerHTML = data.map(p => `
            <tr>
                <td>${p.ticket_id_display}</td>
                <td>
                    ${p.image_url ? `<img src="${p.image_url}" style="height: 40px; width: 60px; object-fit: cover; border-radius: 4px; cursor: pointer; border: 1px solid #ddd;" onclick="openImagePreview('${p.image_url}')" onerror="this.src='https://via.placeholder.com/60x40?text=Error'">` : 'No Image'}
                </td>
                <td>${p.sem_count}</td>
                <td>${p.users?.phone_number || 'Unknown User'}</td>
                <td>
                    <span class="status-pill status-${p.status}">${p.status.toUpperCase()}</span>
                </td>
                <td>
                    <div style="display: flex; gap: 5px;">
                        <button class="btn btn-primary" onclick="updatePrizeStatusWeb('${p.id}', 'verifying', '${p.user_id}')" title="Hold"><i class="fas fa-search"></i></button>
                        <button class="btn btn-accent" onclick="promptApprove('${p.id}', '${p.user_id}')" title="Approve"><i class="fas fa-check"></i></button>
                        <button class="btn" style="background:#ff7675;color:white;" onclick="updatePrizeStatusWeb('${p.id}', 'rejected', '${p.user_id}')" title="Reject"><i class="fas fa-times"></i></button>
                    </div>
                </td>
            </tr>
        `).join('');
}

async function promptApprove(id, userId) {
    const amount = prompt("Enter Winning Amount (₹):", "1000");
    if (amount !== null && !isNaN(amount)) {
        updatePrizeStatusWeb(id, 'approved', userId, parseFloat(amount));
    }
}

async function updatePrizeStatusWeb(id, status, userId, amount = 0) {
    const { error } = await _supabase.from('prize_tickets').update({ status, prize_amount: amount }).eq('id', id);
    if (error) return alert(error.message);

    // Send Notification
    let title = '', msg = '';
    if (status === 'approved') { title = "Prize Approved! 🎉"; msg = "Your ticket has been approved for ₹" + amount; }
    else if (status === 'rejected') { title = "Verification Failed"; msg = "Your ticket was rejected. Contact support."; }
    else if (status === 'verifying') { title = "Verification Underway"; msg = "Admin is manually checking your ticket."; }

    if (title) {
        await _supabase.from('prize_notifications').insert([{ user_id: userId, ticket_id: id, title, message: msg }]);
    }
    
    alert("Ticket Status Updated: " + status);
    loadPrizes();
}

function openImagePreview(url) {
    document.getElementById('preview-image').src = url;
    openModal('imageModal');
}

function switchTab(tabId) {
    document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
    const activeItem = document.querySelector(`[onclick="switchTab('${tabId}')"]`);
    if(activeItem) activeItem.classList.add('active');
    document.getElementById('page-title').innerText = tabId.charAt(0).toUpperCase() + tabId.slice(1);
    ['dashboard-section', 'draws-section', 'bookings-section', 'users-section', 'payments-section', 'notices-section', 'prizes-section'].forEach(s => { if(document.getElementById(s)) document.getElementById(s).style.display = 'none'; });
    if(document.getElementById(tabId + '-section')) document.getElementById(tabId + '-section').style.display = 'block';
    if (tabId === 'dashboard') initDashboard();
    if (tabId === 'draws') loadDraws();
    if (tabId === 'bookings') loadAllBookings();
    if (tabId === 'users') loadAllUsers();
    if (tabId === 'payments') loadAllPayments();
    if (tabId === 'notices') loadNotices();
    if (tabId === 'prizes') loadPrizes();
}

async function sendGlobalNotice() {
    const t = document.getElementById('noticeTitle').value; const c = document.getElementById('noticeContent').value;
    const { error } = await _supabase.from('notices').insert([{ title: t, content: c, type: 'global' }]);
    if(!error) { alert("Notice Shared!"); loadNotices(); }
}

async function sendPrivateMessage() {
    const p = document.getElementById('msgPhone').value; const m = document.getElementById('msgContent').value;
    const { data: u } = await _supabase.from('users').select('id').eq('phone_number', p).single();
    if(u) { await _supabase.from('notifications').insert([{ user_id: u.id, title: 'Admin', message: m }]); alert("Message Sent!"); }
}

async function loadNotices() {
    const { data } = await _supabase.from('notices').select('*').order('created_at', { ascending: false });
    if(data) document.getElementById('active-notices-list').innerHTML = data.map(n => `<div style="background:#f8f9fa; padding:10px; border-radius:8px; margin-bottom:10px; border-left:4px solid var(--primary);"><div style="display:flex; justify-content:space-between;"><strong>${n.title}</strong><button onclick="deleteNotice('${n.id}')" style="background:none; border:none;  cursor:pointer;"><i class="fas fa-trash"></i></button></div><p>${n.content}</p></div>`).join('');
}

async function deleteNotice(id) { await _supabase.from('notices').delete().eq('id', id); loadNotices(); }

function openTicketUpload(id, name) { document.getElementById('target-draw-id').value = id; document.getElementById('target-draw-name').innerText = "Sync for: " + name; openModal('ticketModal'); }
function openResultModal(id) { document.getElementById('result-draw-id').value = id; openModal('resultModal'); }
async function loginWithGoogle() { await _supabase.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: window.location.origin } }); }
function logout() { _supabase.auth.signOut().then(() => location.reload()); }
async function loadRecentBookings() { const { data } = await _supabase.from('tickets').select('*, draws(name), users(phone_number)').limit(5); if(data) document.getElementById('recent-bookings-table').innerHTML = data.map(t => `<tr><td>${t.ticket_number}</td><td>${t.draws?.name}</td><td>${t.users?.phone_number}</td><td>${t.status}</td><td>${new Date(t.created_at).toLocaleDateString()}</td></tr>`).join(''); }

async function loadWithdrawals() {
    const list = document.getElementById('withdrawals-list');
    list.innerHTML = '<tr><td colspan="6" style="text-align:center">Loading requests...</td></tr>';

    const { data, error } = await _supabase
        .from('withdrawals')
        .select()
        .order('created_at', { ascending: false });

    if (error) return alert("Error loading withdrawals: " + error.message);

    list.innerHTML = data.map(w => `
        <tr>
            <td>
                <div style="font-weight:700">${w.user_id.substring(0,8)}...</div>
                <div style="font-size:12px; color:var(--accent)">${w.upi_id || 'N/A'}</div>
            </td>
            <td style="font-weight:900; color:var(--primary)">₹${w.amount}</td>
            <td style="font-size:12px">${w.bank_details || 'UPI Payment'}</td>
            <td>${new Date(w.created_at).toLocaleDateString()}</td>
            <td><span class="status-pill status-${w.status}">${w.status.toUpperCase()}</span></td>
            <td>
                ${w.status === 'pending' ? `
                    <button class="btn btn-primary" onclick="updateWithdrawalStatus('${w.id}', 'completed')" style="padding: 5px 10px; font-size: 11px; background: #10B981;">Release</button>
                    <button class="btn" onclick="updateWithdrawalStatus('${w.id}', 'rejected')" style="padding: 5px 10px; font-size: 11px; background: #ff7675;">Reject</button>
                ` : '---'}
            </td>
        </tr>
    `).join('');
}

async function updateWithdrawalStatus(id, status) {
    if (!confirm(`Are you sure you want to mark this as ${status}?`)) return;

    const { error } = await _supabase
        .from('withdrawals')
        .update({ status })
        .eq('id', id);

    if (!error) {
        alert("Status updated successfully!");
        loadWithdrawals();
    } else {
        alert("Error: " + error.message);
    }
}

window.onload = async () => {
    const { data: { session } } = await _supabase.auth.getSession();
    if (session) verifyAdmin(session.user);
};
