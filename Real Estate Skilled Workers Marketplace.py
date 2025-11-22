import streamlit as st
import mysql.connector
from mysql.connector import Error
import pandas as pd
from datetime import date

st.set_page_config(page_title="🏠 Real Estate Marketplace", layout="wide")

# ----------------------------
# Sidebar: Database connection
# ----------------------------
st.sidebar.header("⚙️ Database Connection Settings")
db_host = st.sidebar.text_input("MySQL Host", value="localhost")
db_port = st.sidebar.number_input("MySQL Port", value=3306, step=1)
db_user = st.sidebar.text_input("MySQL Username", value="root")
db_pass = st.sidebar.text_input("MySQL Password", type="password")
db_name = st.sidebar.text_input("Database Name", value="Realestate")

if st.sidebar.button("Reconnect"):
    st.rerun()

# ----------------------------
# Create DB connection
# ----------------------------
def create_connection():
    try:
        conn = mysql.connector.connect(
            host=db_host,
            port=int(db_port),
            user=db_user,
            password=db_pass,
            database=db_name
        )
        if conn.is_connected():
            return conn
    except Error as e:
        st.error(f"MySQL Connection Failed: {e}")
    return None

# ----------------------------
# Authentication
# ----------------------------
def check_login(username, password):
    if username == "admin" and password == "admin123":
        return "admin"
    elif username == "user" and password == "user123":
        return "readonly"
    return None

# ----------------------------
# DB helpers
# ----------------------------
def run_fetch(query, params=None, cols=None):
    conn = create_connection()
    if not conn:
        return pd.DataFrame([], columns=cols if cols else [])
    try:
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        rows = cursor.fetchall()
        return pd.DataFrame(rows, columns=cols if cols else [])
    except Exception as e:
        st.error(f"Query failed: {e}")
        return pd.DataFrame([], columns=cols if cols else [])
    finally:
        conn.close()

def run_commit(query, params=None):
    if st.session_state.get("role") == "readonly":
        st.warning("⚠️ You have read-only access. Modifications are not allowed.")
        return False
    conn = create_connection()
    if not conn:
        return False
    try:
        cursor = conn.cursor()
        cursor.execute(query, params or ())
        conn.commit()
        return True
    except Exception as e:
        st.error(f"Operation failed: {e}")
        return False
    finally:
        conn.close()

def run_call(proc_name, params=None):
    conn = create_connection()
    if not conn:
        return pd.DataFrame()
    try:
        cursor = conn.cursor()
        if params:
            cursor.callproc(proc_name, params)
        else:
            cursor.callproc(proc_name)
        results = []
        for result in cursor.stored_results():
            results.extend(result.fetchall())
            cols = result.column_names
        conn.commit()
        if results:
            return pd.DataFrame(results, columns=cols)
        return pd.DataFrame()
    except Exception as e:
        st.error(f"Procedure call failed: {e}")
        return pd.DataFrame()
    finally:
        conn.close()

# ----------------------------
# Common UI helpers
# ----------------------------
def show_df(df):
    if df.empty:
        st.info("No data found.")
    else:
        st.dataframe(df, use_container_width=True)

def restrict_action(default="View"):
    if st.session_state.get("role") == "readonly":
        return default
    return st.selectbox("Action", ["View", "Add", "Update", "Delete"])

# ----------------------------
# CRUD SECTIONS
# ----------------------------
def manage_customer():
    st.header("👥 Customers")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Customer",
                       cols=["Cust_Id", "Name", "Phone", "Email", "City", "State", "PINCODE"])
        show_df(df)
    elif action == "Add":
        cid = st.number_input("Customer ID", min_value=1)
        name = st.text_input("Name")
        phone = st.text_input("Phone")
        email = st.text_input("Email")
        city = st.text_input("City")
        state = st.text_input("State")
        pincode = st.text_input("PINCODE")
        if st.button("Add Customer"):
            ok = run_commit("INSERT INTO Customer VALUES (%s,%s,%s,%s,%s,%s,%s)",
                            (cid, name, phone, email, city, state, pincode))
            if ok:
                st.success("✅ Customer added.")

    elif action == "Update":
        cid = st.number_input("Customer ID", min_value=1)
        name = st.text_input("New Name")
        city = st.text_input("New City")
        if st.button("Update"):
            ok = run_commit("UPDATE Customer SET Name=%s, City=%s WHERE Cust_Id=%s",
                            (name, city, cid))
            if ok:
                st.success("✅ Customer updated.")

    elif action == "Delete":
        cid = st.number_input("Customer ID", min_value=1)
        if st.button("Delete"):
            ok = run_commit("DELETE FROM Customer WHERE Cust_Id=%s", (cid,))
            if ok:
                st.warning("🗑 Customer deleted.")

def manage_workers():
    st.header("👷 Workers")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Workers",
                       cols=["W_Id", "Name", "Phone", "Email", "State", "PINCODE"])
        show_df(df)
    elif action == "Add":
        wid = st.number_input("Worker ID", min_value=1)
        name = st.text_input("Name")
        phone = st.text_input("Phone")
        email = st.text_input("Email")
        state = st.text_input("State")
        pin = st.text_input("PINCODE")
        if st.button("Add Worker"):
            ok = run_commit("INSERT INTO Workers VALUES (%s,%s,%s,%s,%s,%s)",
                            (wid, name, phone, email, state, pin))
            if ok:
                st.success("✅ Worker added.")
    elif action == "Update":
        wid = st.number_input("Worker ID", min_value=1)
        new_state = st.text_input("New State")
        if st.button("Update"):
            ok = run_commit("UPDATE Workers SET State=%s WHERE W_Id=%s", (new_state, wid))
            if ok:
                st.success("✅ Worker updated.")
    else:
        wid = st.number_input("Worker ID", min_value=1)
        if st.button("Delete Worker"):
            ok = run_commit("DELETE FROM Workers WHERE W_Id=%s", (wid,))
            if ok:
                st.warning("🗑 Worker deleted.")

def manage_job():
    st.header("🧾 Jobs")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Job",
                       cols=["Job_Id", "Title", "Description", "Status", "Cust_Id"])
        show_df(df)
    elif action == "Add":
        jid = st.number_input("Job ID", min_value=1)
        title = st.text_input("Title")
        desc = st.text_area("Description")
        status = st.selectbox("Status", ["Open", "Ongoing", "Closed"])
        cust = st.number_input("Customer ID (nullable)", min_value=0, value=0)
        if st.button("Add Job"):
            run_commit("INSERT INTO Job VALUES (%s,%s,%s,%s,%s)",
                       (jid, title, desc, status, cust if cust != 0 else None))
            st.success("✅ Job added.")
    elif action == "Update":
        jid = st.number_input("Job ID", min_value=1)
        status = st.selectbox("New Status", ["Open", "Ongoing", "Closed"])
        if st.button("Update Job"):
            run_commit("UPDATE Job SET Status=%s WHERE Job_Id=%s", (status, jid))
            st.success("✅ Job updated.")
    else:
        jid = st.number_input("Job ID", min_value=1)
        if st.button("Delete Job"):
            run_commit("DELETE FROM Job WHERE Job_Id=%s", (jid,))
            st.warning("🗑 Job deleted.")

def manage_bids():
    st.header("💰 Bids")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Bids",
                       cols=["Bid_Id", "Amount", "Date", "Job_Id"])
        show_df(df)
    elif action == "Add":
        bid = st.number_input("Bid ID", min_value=1)
        amt = st.number_input("Amount", min_value=0.0)
        job = st.number_input("Job ID", min_value=1)
        if st.button("Add Bid"):
            run_commit("INSERT INTO Bids VALUES (%s,%s,CURDATE(),%s)", (bid, amt, job))
            st.success("✅ Bid added.")

def manage_contract():
    st.header("📜 Contracts")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Contract",
                       cols=["Co_Id", "Start_date", "End_date", "Status", "Cust_Id", "Job_Id"])
        show_df(df)
    elif action == "Add":
        coid = st.number_input("Contract ID", min_value=1)
        sdate = st.date_input("Start Date")
        edate = st.date_input("End Date")
        cust = st.number_input("Customer ID", min_value=1)
        job = st.number_input("Job ID", min_value=1)
        if st.button("Add Contract"):
            run_commit("INSERT INTO Contract (Co_Id, Start_date, End_date, Status, Cust_Id, Job_Id) VALUES (%s,%s,%s,'Active',%s,%s)",
                       (coid, sdate, edate, cust, job))
            st.success("✅ Contract added.")

def manage_payment():
    st.header("💵 Payments")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Payment",
                       cols=["P_Id", "Amount", "Date", "Status", "Co_Id"])
        show_df(df)
    elif action == "Add":
        pid = st.number_input("Payment ID", min_value=1)
        amt = st.number_input("Amount", min_value=0.0)
        coid = st.number_input("Contract ID", min_value=1)
        status = st.selectbox("Status", ["Pending", "Completed"])
        if st.button("Add Payment"):
            run_commit("INSERT INTO Payment VALUES (%s,%s,CURDATE(),%s,%s)", (pid, amt, status, coid))
            st.success("✅ Payment added.")

def manage_location():
    st.header("📍 Locations")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Location",
                       cols=["L_Id", "Job_Id", "Street", "City", "State", "PINCODE"])
        show_df(df)
    elif action == "Add":
        lid = st.number_input("Location ID", min_value=1)
        job = st.number_input("Job ID", min_value=1)
        street = st.text_input("Street")
        city = st.text_input("City")
        state = st.text_input("State")
        pin = st.text_input("PINCODE")
        if st.button("Add Location"):
            run_commit("INSERT INTO Location VALUES (%s,%s,%s,%s,%s,%s)",
                       (lid, job, street, city, state, pin))
            st.success("✅ Location added.")

def manage_ratings():
    st.header("⭐ Ratings")
    action = restrict_action()
    if action == "View":
        df = run_fetch("SELECT * FROM Ratings",
                       cols=["R_Id", "Score", "Date", "Cust_Id", "W_Id", "Job_Id"])
        show_df(df)
    elif action == "Add":
        rid = st.number_input("Rating ID", min_value=1)
        score = st.slider("Score (1-10)", 1, 10)
        cust = st.number_input("Customer ID", min_value=1)
        wid = st.number_input("Worker ID", min_value=1)
        job = st.number_input("Job ID", min_value=1)
        if st.button("Add Rating"):
            run_commit("INSERT INTO Ratings VALUES (%s,%s,CURDATE(),%s,%s,%s)",
                       (rid, score, cust, wid, job))
            st.success("✅ Rating added.")

# ----------------------------
# Utilities (procedures/functions)
# ----------------------------
def utilities_panel():
    st.header("🧰 Utilities & Reports")
    st.subheader("Stored Procedures & Functions")

    wid = st.number_input("Worker ID for Earnings", min_value=1)
    if st.button("Get Worker Earnings"):
        df = run_call("GetWorkerEarnings", (wid,))
        show_df(df)

    city = st.text_input("City for Open Jobs")
    if st.button("Get Open Jobs by City"):
        df = run_call("GetOpenJobsByCity", (city,))
        show_df(df)

    st.write("---")
    wid2 = st.number_input("Worker ID (Avg Rating)", min_value=1, key="avgid")
    if st.button("Show Avg Rating"):
        df = run_fetch("SELECT avg_rating(%s)", (wid2,), cols=["AvgRating"])
        show_df(df)

    jid = st.number_input("Job ID (Total Bids)", min_value=1, key="totbid")
    if st.button("Show Total Bids"):
        df = run_fetch("SELECT total_bids(%s)", (jid,), cols=["TotalBids"])
        show_df(df)

# ----------------------------
# Main App
# ----------------------------
def main():
    st.title("🏠 Real Estate Skilled Workers Marketplace")

    if "logged_in" not in st.session_state:
        st.session_state["logged_in"] = False
        st.session_state["role"] = None

    if not st.session_state["logged_in"]:
        st.subheader("🔐 Login")
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")
        if st.button("Login"):
            role = check_login(username, password)
            if role:
                st.session_state["logged_in"] = True
                st.session_state["role"] = role
                st.success(f"✅ Logged in as {role.upper()}")
                st.rerun()
            else:
                st.error("❌ Invalid credentials")
        return

    conn = create_connection()
    if conn:
        st.success(f"Connected to database: {db_name}")
        conn.close()
    else:
        st.error("Database connection failed.")
        return

    if st.session_state["role"] == "readonly":
        st.sidebar.info("👤 Logged in as: Limited User (View Only)")
    else:
        st.sidebar.success("👑 Logged in as: Admin")

    menu = st.sidebar.radio("📋 Menu", [
        "Customer", "Workers", "Job", "Bids", "Contract",
        "Payment", "Location", "Ratings", "Utilities / Reports", "Logout"
    ])

    if menu == "Customer": manage_customer()
    elif menu == "Workers": manage_workers()
    elif menu == "Job": manage_job()
    elif menu == "Bids": manage_bids()
    elif menu == "Contract": manage_contract()
    elif menu == "Payment": manage_payment()
    elif menu == "Location": manage_location()
    elif menu == "Ratings": manage_ratings()
    elif menu == "Utilities / Reports": utilities_panel()
    elif menu == "Logout":
        st.session_state["logged_in"] = False
        st.session_state["role"] = None
        st.rerun()

if __name__ == "__main__":
    main()
