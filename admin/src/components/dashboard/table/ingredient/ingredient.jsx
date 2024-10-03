import React, { useState, useEffect } from "react";
import axios from "axios";
import Swal from "sweetalert2";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import IngredientAdd from "./ingredient_add.jsx";
import IngredientEdit from "./ingredient_edit.jsx";

const Ingredients = () => {
  const [ingredients, setIngredients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // Pagination states
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  // Toggle Sidebar
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  // Fetch ingredients from the API
  const fetchIngredients = async () => {
    try {
      const response = await axios.get(
        `${import.meta.env.VITE_API_URL_GET_INGREDIENTS}`
      );
      setIngredients(response.data);
      setLoading(false);
    } catch (err) {
      setError(err);
      setLoading(false);
    }
  };

  // useEffect to load ingredients data on component mount
  useEffect(() => {
    fetchIngredients();
  }, []);

  // Handle search
  const handleSearch = (event) => {
    setSearchTerm(event.target.value);
    setCurrentPage(1); // Reset to page 1 when searching
  };

  // Filter ingredients based on search term
  const filteredIngredients = ingredients.filter((ingredient) =>
    ingredient.ingredient_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  // Pagination logic
  const totalPages = Math.ceil(filteredIngredients.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const currentItems = filteredIngredients.slice(
    startIndex,
    startIndex + itemsPerPage
  );

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  // Generate pagination numbers with ellipsis
  const getPageNumbers = () => {
    const pageNumbers = [];
    if (totalPages <= 5) {
      for (let i = 1; i <= totalPages; i++) {
        pageNumbers.push(i);
      }
    } else {
      if (currentPage <= 3) {
        pageNumbers.push(1, 2, 3, 4, "...", totalPages);
      } else if (currentPage > totalPages - 3) {
        pageNumbers.push(
          1,
          "...",
          totalPages - 3,
          totalPages - 2,
          totalPages - 1,
          totalPages
        );
      } else {
        pageNumbers.push(
          1,
          "...",
          currentPage - 1,
          currentPage,
          currentPage + 1,
          "...",
          totalPages
        );
      }
    }
    return pageNumbers;
  };

  // Handle delete ingredient
  const handleDelete = (id) => {
    console.log("Attempting to delete ID:", id); // Log ID for debugging
    Swal.fire({
      title: "Are you sure?",
      text: "You will not be able to recover this data!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "Yes, delete it!",
      cancelButtonText: "Cancel",
    }).then((result) => {
      if (result.isConfirmed) {
        axios
          .delete(`${import.meta.env.VITE_API_URL_GET_INGREDIENTS}`, {
            data: { id: id }, // ส่งค่า id ผ่าน body
            headers: {
              "Content-Type": "application/json",
            },
          })
          .then(() => {
            setIngredients(
              ingredients.filter(
                (ingredient) => ingredient.ingredient_id !== id
              )
            );
            Swal.fire(
              "Deleted!",
              "The ingredient has been deleted.",
              "success"
            );
          })
          .catch((error) => {
            console.error("Deletion error:", error); // Log error for debugging
            Swal.fire("Error!", "Failed to delete the ingredient.", "error");
          });
      }
    });
  };

  // Handle view details
  const handleViewDetails = (ingredient) => {
    Swal.fire({
      title: `
        <div class="text-2xl font-semibold text-gray-800">${ingredient.ingredient_name}</div>
      `,
      html: `
        <div class="flex flex-col items-center gap-4 max-w-md mx-auto">
          <!-- Image Section -->
          <img src="${ingredient.image_url}" alt="${ingredient.ingredient_name}"
            class="w-24 h-24 object-contain mb-4"/>
  
          <!-- Nutrition Information Grid -->
          <div class="grid grid-cols-2 gap-4 w-full">
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Calories:</strong> ${
                ingredient.calories
              } kcal</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Quantity:</strong> ${
                ingredient.quantity_per_unit
              }g</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Protein:</strong> ${
                ingredient.protien
              }g</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Fat:</strong> ${
                ingredient.fat
              }g</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Carbs:</strong> ${
                ingredient.carbohydrates
              }g</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Fiber:</strong> ${
                ingredient.dietary_fiber
              }g</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Calcium:</strong> ${
                ingredient.calcium
              }mg</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Iron:</strong> ${
                ingredient.iron
              }mg</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Vitamin C:</strong> ${
                ingredient.vitamin_c
              }mg</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Sodium:</strong> ${
                ingredient.sodium
              }mg</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Sugar:</strong> ${
                ingredient.sugar
              }g</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Cholesterol:</strong> ${
                ingredient.cholesterol
              }mg</p>
            </div>
            <div class="col-span-2 bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>Created At:</strong> ${new Date(
                ingredient.created_at
              ).toLocaleDateString()}</p>
            </div>
          </div>
        </div>
      `,
      showCloseButton: true,
      confirmButtonColor: "#3085d6",
      confirmButtonText: "Close",
      customClass: {
        popup: "rounded-lg p-6 max-w-3xl", // Limit the width of the popup
      },
    });
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-200">
      <Sidebar isSidebarOpen={isSidebarOpen} />
      <div className="flex-1 p-8">
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-bold text-center mb-8 text-gray-800">
          Ingredients List
        </h1>

        {/* Search Box */}
        <div className="flex justify-between mb-6">
          <input
            type="text"
            placeholder="Search for ingredients"
            className="w-full max-w-lg px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 shadow-md"
            value={searchTerm}
            onChange={handleSearch}
          />
          <IngredientAdd onAdd={fetchIngredients} />
        </div>

        {/* Ingredients Table */}
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white shadow-lg rounded-lg overflow-hidden">
            <thead>
              <tr className="bg-gradient-to-r from-blue-500 to-blue-600 text-white">
                <th className="py-4 px-6 text-left">#</th>
                <th className="py-4 px-6 text-left">Image</th>
                <th className="py-4 px-6 text-left">Name</th>
                <th className="py-4 px-6 text-left">Calories</th>
                <th className="py-4 px-6 text-center">Actions</th>
              </tr>
            </thead>
            <tbody>
              {currentItems.map((ingredient, index) => (
                <tr
                  key={ingredient.ingredient_id}
                  className={`border-b ${
                    index % 2 === 0 ? "bg-gray-100" : "bg-white"
                  } hover:bg-blue-50 transition duration-300`}
                >
                  <td className="py-4 px-6">{startIndex + index + 1}</td>
                  <td className="py-4 px-6">
                    <img
                      src={ingredient.image_url}
                      alt={ingredient.ingredient_name}
                      className="w-16 h-16 object-cover rounded-full shadow-md"
                    />
                  </td>
                  <td className="py-4 px-6">{ingredient.ingredient_name}</td>
                  <td className="py-4 px-6">{ingredient.calories} kcal</td>
                  <td className="py-4 px-6 text-center">
                    <button
                      onClick={() => handleViewDetails(ingredient)}
                      className="bg-blue-400 hover:bg-blue-500 text-white px-3 py-1 rounded-full mr-2 shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
                    >
                      View
                    </button>
                    <IngredientEdit
                      ingredient={ingredient}
                      onEdit={fetchIngredients}
                    />
                    <button
                      onClick={() => handleDelete(ingredient.ingredient_id)}
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

        {/* Pagination */}
        <div className="flex justify-center mt-8 space-x-2">
          <button
            onClick={() => handlePageChange(currentPage - 1)}
            disabled={currentPage === 1}
            className="px-3 py-2 rounded-full bg-gray-200 hover:bg-gray-300 transition duration-300 disabled:opacity-50"
          >
            Previous
          </button>
          {getPageNumbers().map((pageNumber, index) => (
            <button
              key={index}
              onClick={() =>
                typeof pageNumber === "number" && handlePageChange(pageNumber)
              }
              className={`px-3 py-2 rounded-full ${
                currentPage === pageNumber
                  ? "bg-blue-500 text-white"
                  : "bg-gray-200 hover:bg-gray-300"
              } transition duration-300`}
              disabled={typeof pageNumber !== "number"}
            >
              {pageNumber}
            </button>
          ))}
          <button
            onClick={() => handlePageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
            className="px-3 py-2 rounded-full bg-gray-200 hover:bg-gray-300 transition duration-300 disabled:opacity-50"
          >
            Next
          </button>
        </div>
      </div>
    </div>
  );
};

export default Ingredients;
