import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";

const FoodMenuByCategory = () => {
  const [foodItems, setFoodItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");
  const itemsPerPage = 8;
  const [isSidebarOpen, setIsSidebarOpen] = useState(true); // Sidebar toggle state

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  useEffect(() => {
    const fetchFoodItems = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_FOOD_MENU_BY_CATEGORY}`
        );
        setFoodItems(response.data);
        setLoading(false);
      } catch (err) {
        setError(err);
        setLoading(false);
      }
    };

    fetchFoodItems();
  }, []);

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1); // Reset to first page on new search
  };

  // Filter items based on search term
  const filteredItems = foodItems.filter(
    (item) =>
      item.menu_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.category_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Pagination logic
  const totalPages = Math.ceil(filteredItems.length / itemsPerPage);
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = filteredItems.slice(indexOfFirstItem, indexOfLastItem);

  const goToPage = (page) => {
    setCurrentPage(page);
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-50 to-gray-200">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />
      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-extrabold text-center mb-8 text-gray-800">
          Food Menu
        </h1>

        {/* Search Box */}
        <div className="flex justify-center mb-8">
          <input
            type="text"
            placeholder="Search by name or category"
            className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-lg"
            value={searchTerm}
            onChange={handleSearch}
          />
        </div>

        {/* Food Items */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {currentItems.map((item) => (
            <div
              key={item.menu_id}
              className="bg-white rounded-lg shadow-md hover:shadow-2xl transition duration-300 transform hover:scale-105 overflow-hidden relative"
            >
              {/* Card Header with Image */}
              <div className="relative h-36 bg-gradient-to-b from-white to-gray-50 flex items-center justify-center p-4">
                {item.image_url ? (
                  <img
                    src={item.image_url}
                    alt={item.menu_name}
                    className="max-h-full object-contain"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-gray-200 rounded-md">
                    <span className="text-gray-700">No Image</span>
                  </div>
                )}
                {/* Optional Badge */}
                <div className="absolute top-2 right-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-white px-2 py-1 rounded-lg text-xs font-semibold shadow-md">
                  {item.category_name}
                </div>
              </div>

              {/* Card Body */}
              <div className="p-4 text-center">
                <h2 className="text-lg font-semibold mb-2 text-gray-800">
                  {item.menu_name}
                </h2>

                <p className="text-xs text-gray-400">
                  <strong>Created at:</strong>{" "}
                  {new Date(item.created_at).toLocaleDateString()}
                </p>

                {/* View Details Button */}
                <button className="mt-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white px-3 py-1 rounded-full hover:from-blue-600 hover:to-purple-600 transition duration-300 transform hover:scale-105 shadow-lg">
                  View Details
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Pagination */}
        <div className="flex justify-center mt-8 space-x-2">
          {Array.from({ length: totalPages }, (_, index) => (
            <button
              key={index}
              onClick={() => goToPage(index + 1)}
              className={`px-4 py-2 rounded-full ${
                currentPage === index + 1
                  ? "bg-blue-500 text-white"
                  : "bg-gray-200 text-gray-700"
              } transition duration-300`}
            >
              {index + 1}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
};

export default FoodMenuByCategory;
