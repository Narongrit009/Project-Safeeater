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
      title: "คุณแน่ใจหรือไม่?",
      text: "คุณจะไม่สามารถกู้คืนข้อมูลนี้ได้!",
      icon: "warning",
      showCancelButton: true,
      confirmButtonColor: "#d33",
      cancelButtonColor: "#3085d6",
      confirmButtonText: "ใช่, ลบเลย!",
      cancelButtonText: "ยกเลิก",
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
              <p class="text-sm text-gray-600"><strong>แคลอรี่:</strong> ${
                ingredient.calories
              } แคลอรี่</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>ปริมาณ:</strong> ${
                ingredient.quantity_per_unit
              } กรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>โปรตีน:</strong> ${
                ingredient.protien
              } กรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>ไขมัน:</strong> ${
                ingredient.fat
              } กรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>คาร์โบไฮเดรต:</strong> ${
                ingredient.carbohydrates
              } กรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>ไฟเบอร์:</strong> ${
                ingredient.dietary_fiber
              } กรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>แคลเซียม:</strong> ${
                ingredient.calcium
              } มิลลิกรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>เหล็ก:</strong> ${
                ingredient.iron
              } มิลลิกรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>วิตามินซี:</strong> ${
                ingredient.vitamin_c
              } มิลิกรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>โซเดียม:</strong> ${
                ingredient.sodium
              } มิลลิกรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>น้ำตาล:</strong> ${
                ingredient.sugar
              } กรัม</p>
            </div>
            <div class="bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>คอเลสเตอรอล:</strong> ${
                ingredient.cholesterol
              } มิลิกรัม</p>
            </div>
            <div class="col-span-2 bg-gray-100 p-3 rounded-lg shadow-sm text-center">
              <p class="text-sm text-gray-600"><strong>สร้างเมื่อวันที่:</strong> ${new Date(
                ingredient.created_at
              ).toLocaleDateString()}</p>
            </div>
          </div>
        </div>
      `,
      showCloseButton: true,
      confirmButtonColor: "#3085d6",
      confirmButtonText: "ปิด",
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
          รายการวัตถุดิบ
        </h1>

        {/* Search Box */}
        <div className="flex justify-between mb-6">
          <input
            type="text"
            placeholder="ค้นหาชื่อวัตถุดิบ"
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
                <th className="py-4 px-6 text-left">รูปภาพ</th>
                <th className="py-4 px-6 text-left">ชื่อวัตถุดิบ</th>
                <th className="py-4 px-6 text-left">แคลอรี่</th>
                <th className="py-4 px-6 text-center">การจัดการ</th>
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
                      ดูเพิ่มเติม
                    </button>
                    <IngredientEdit
                      ingredient={ingredient}
                      onEdit={fetchIngredients}
                    />
                    <button
                      onClick={() => handleDelete(ingredient.ingredient_id)}
                      className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-full shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
                    >
                      ลบ
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
            หน้าก่อนหน้า
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
            หน้าต่อไป
          </button>
        </div>
      </div>
    </div>
  );
};

export default Ingredients;
