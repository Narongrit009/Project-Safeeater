import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import Swal from "sweetalert2"; // Import SweetAlert2 for alerts
import FoodCategoriesAdd from "./foodcategories_add.jsx";
import FoodCategoriesEdit from "./foodcategories_edit.jsx";

const FoodCategories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState(""); // For search functionality
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // Toggle Sidebar
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  // Fetch categories from the API
  const fetchCategories = async () => {
    try {
      const response = await axios.get(
        `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}`
      );
      setCategories(response.data);
      setLoading(false);
    } catch (err) {
      setError(err);
      setLoading(false);
    }
  };

  // Call fetchCategories when the component is mounted
  useEffect(() => {
    fetchCategories();
  }, []);

  // Handle search input
  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
  };

  // Filter categories based on search input
  const filteredCategories = categories.filter((category) =>
    category.category_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Handle delete action
  const handleDelete = (id) => {
    Swal.fire({
      title: "Are you sure?",
      text: "This action cannot be undone!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Yes, delete it!",
      cancelButtonText: "Cancel",
    }).then((result) => {
      if (result.isConfirmed) {
        // Call API to delete the category
        axios
          .delete(
            `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}?id=${id}`
          )
          .then(() => {
            // Update the list after deletion
            setCategories(categories.filter((category) => category.id !== id));
            Swal.fire("Deleted!", "The category has been deleted.", "success");
          })
          .catch((error) => {
            Swal.fire("Error!", "Failed to delete the category.", "error");
          });
      }
    });
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-200">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />

      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-bold text-center mb-8 text-gray-800">
          Food Categories
        </h1>

        {/* Search Box */}
        <div className="flex justify-between mb-6">
          <input
            type="text"
            placeholder="Search for categories"
            className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-md"
            value={searchTerm}
            onChange={handleSearch}
          />
          <FoodCategoriesAdd onAdd={fetchCategories} />
        </div>

        {/* Categories Table */}
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white shadow-md rounded-lg overflow-hidden">
            <thead>
              <tr className="bg-blue-500 text-white">
                <th className="py-3 px-4 text-left">#</th>
                <th className="py-3 px-4 text-left">Category Name</th>
                <th className="py-3 px-4 text-left">Description</th>
                <th className="py-3 px-4 text-center">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredCategories.map((category, index) => (
                <tr
                  key={category.id}
                  className={`border-b ${
                    index % 2 === 0 ? "bg-gray-100" : "bg-white"
                  } hover:bg-blue-50 transition duration-300`}
                >
                  <td className="py-3 px-4">{index + 1}</td>
                  <td className="py-3 px-4">{category.category_name}</td>
                  <td className="py-3 px-4">{category.description}</td>
                  <td className="py-3 px-4 text-center">
                    <FoodCategoriesEdit
                      category={category}
                      onEdit={fetchCategories}
                    />

                    <button
                      onClick={() => handleDelete(category.id)}
                      className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-full shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default FoodCategories;
