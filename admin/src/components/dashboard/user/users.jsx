import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../sidebar.jsx";
import Navbar from "../navbar.jsx";

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true); // สถานะเปิด/ปิด Sidebar
  const [searchTerm, setSearchTerm] = useState(""); // เก็บคำค้นหา
  const [currentPage, setCurrentPage] = useState(1); // สถานะหน้าใน pagination
  const itemsPerPage = 6; // จำนวนข้อมูลต่อหน้า
  const [showOptions, setShowOptions] = useState(false);

  // ฟังก์ชันสลับสถานะ Sidebar
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  // Fetch ข้อมูลผู้ใช้งานจาก API
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_USERS}`
        );
        setUsers(response.data);
        setLoading(false);
      } catch (err) {
        setError(err);
        setLoading(false);
      }
    };

    fetchUsers();
  }, []);

  // ฟิลเตอร์ข้อมูลที่ค้นหา
  const filteredUsers = users.filter((user) => {
    return (
      user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  const toggleOptions = () => {
    setShowOptions(!showOptions); // สลับการแสดงผลเมนูเมื่อกดปุ่ม
  };

  // คำนวณข้อมูลที่จะแสดงในหน้าปัจจุบัน
  const indexOfLastUser = currentPage * itemsPerPage;
  const indexOfFirstUser = indexOfLastUser - itemsPerPage;
  const currentUsers = filteredUsers.slice(indexOfFirstUser, indexOfLastUser);

  // คำนวณจำนวนหน้าทั้งหมด
  const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        Loading...
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center text-red-500">
        Error loading users: {error.message}
      </div>
    );
  }

  return (
    <div className="min-h-screen flex bg-gray-100">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />

      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        {/* User Information */}
        <h1 className="text-4xl font-bold text-center mt-10 mb-5 text-gray-800">
          User Information
        </h1>

        {/* Search Box */}
        <div className="flex justify-center mb-8">
          <div className="relative w-full max-w-lg">
            {/* Icon search */}
            <span className="absolute inset-y-0 left-3 flex items-center pointer-events-none text-gray-500">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M10 4a6 6 0 100 12 6 6 0 000-12zm8 8l-4-4"
                />
              </svg>
            </span>
            <input
              type="text"
              placeholder="Search by username or email"
              className="pl-10 pr-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 w-full shadow-lg transition-transform duration-300 ease-in-out hover:scale-105"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-12">
          {currentUsers.map((user) => (
            <div
              key={user.user_id}
              className="bg-white p-6 rounded-lg shadow-lg hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2"
            >
              {/* Icon จุดสามจุด */}
              <div className="absolute top-3 right-3">
                <button className="text-gray-500 hover:text-gray-700">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M12 6v.01M12 12v.01M12 18v.01"
                    />
                  </svg>
                </button>
              </div>

              {/* Image Section */}
              <div className="flex justify-center mb-4">
                {user.image_url ? (
                  <img
                    src={user.image_url}
                    alt={user.username}
                    className="w-24 h-24 rounded-full object-cover border-4 border-blue-400 shadow-md"
                  />
                ) : (
                  <div className="w-24 h-24 rounded-full bg-gray-300 flex items-center justify-center shadow-md">
                    <span className="text-gray-700">No Image</span>
                  </div>
                )}
              </div>

              {/* Username and Email */}
              <h2 className="text-2xl font-bold text-center mb-2 text-gray-800">
                {user.username}
              </h2>
              <p className="text-center text-gray-500 text-sm italic mb-4">
                {user.email}
              </p>

              {/* User Info Section */}
              <div className="grid grid-cols-2 gap-x-6 gap-y-4 text-sm text-gray-600">
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M2.003 5.884l8-3.2a1 1 0 01.994 0l8 3.2a1 1 0 01.575.922v6.4a1 1 0 01-.575.922l-8 3.2a1 1 0 01-.994 0l-8-3.2A1 1 0 012 13.206v-6.4a1 1 0 01.003-.922z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Tel:</span> {user.tel || "N/A"}
                </div>
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 2a5 5 0 100 10A5 5 0 1010 2z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Gender:</span>{" "}
                  {user.gender || "N/A"}
                </div>
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M6 3a3 3 0 106 0 3 3 0 00-6 0zm-2 9a5 5 0 0110 0v4H4v-4z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Birthday:</span>{" "}
                  {user.birthday || "N/A"}
                </div>
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 2a5 5 0 100 10A5 5 0 1010 2z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Height:</span>{" "}
                  {user.height ? `${user.height} cm` : "N/A"}
                </div>
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 2a5 5 0 100 10A5 5 0 1010 2z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Weight:</span>{" "}
                  {user.weight ? `${user.weight} kg` : "N/A"}
                </div>
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M2.003 5.884l8-3.2a1 1 0 01.994 0l8 3.2a1 1 0 01.575.922v6.4a1 1 0 01-.575.922l-8 3.2a1 1 0 01-.994 0l-8-3.2A1 1 0 012 13.206v-6.4a1 1 0 01.003-.922z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Chronic Diseases:</span>{" "}
                  {user.chronic_diseases || "N/A"}
                </div>
                <div className="flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-5 w-5 mr-2 text-blue-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fillRule="evenodd"
                      d="M10 2a5 5 0 100 10A5 5 0 1010 2z"
                      clipRule="evenodd"
                    />
                  </svg>
                  <span className="font-medium">Food Allergies:</span>{" "}
                  {user.food_allergies || "N/A"}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Pagination */}
        <div className="flex justify-center mt-10">
          <nav className="inline-flex">
            {[...Array(totalPages)].map((_, index) => (
              <button
                key={index}
                onClick={() => handlePageChange(index + 1)}
                className={`px-4 py-2 border rounded-lg mx-1 ${
                  currentPage === index + 1
                    ? "bg-blue-500 text-white"
                    : "bg-white text-blue-500"
                } hover:bg-blue-500 hover:text-white transition duration-300`}
              >
                {index + 1}
              </button>
            ))}
          </nav>
        </div>
      </div>
    </div>
  );
};

export default Users;
