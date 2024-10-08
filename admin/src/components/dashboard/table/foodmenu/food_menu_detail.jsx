import React, { useState, useEffect } from "react";
import axios from "axios";
import { useParams } from "react-router-dom";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";

const FoodMenuDetail = () => {
  const { menuId } = useParams(); // รับค่า menuId จาก URL
  const [menuData, setMenuData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // ฟังก์ชัน toggle สำหรับ Sidebar
  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  useEffect(() => {
    const fetchMenuDetail = async () => {
      try {
        const response = await axios.get(
          `${
            import.meta.env.VITE_API_URL_GET_FOOD_MENU_DETAIL
          }?menu_id=${menuId}`
        );
        setMenuData(response.data.data);
        setLoading(false);
      } catch (err) {
        setError(err);
        setLoading(false);
      }
    };

    fetchMenuDetail();
  }, [menuId]);

  if (loading)
    return (
      <div className="text-center text-2xl font-bold mt-20">กำลังโหลด...</div>
    );
  if (error)
    return (
      <div className="text-center text-red-500 text-2xl mt-20">
        เกิดข้อผิดพลาด: {error.message}
      </div>
    );
  if (!menuData)
    return (
      <div className="text-center text-gray-500 text-2xl mt-20">
        ไม่พบข้อมูลเมนู
      </div>
    );

  return (
    <div className="min-h-screen flex bg-gray-50">
      {/* Sidebar */}
      <Sidebar isSidebarOpen={isSidebarOpen} />
      {/* Main Content */}
      <div className="flex-1 p-8">
        {/* Navbar */}
        <Navbar toggleSidebar={toggleSidebar} />
        <div className="max-w-4xl mx-auto">
          <h1 className="text-3xl font-bold text-center mb-6 text-gray-900 tracking-wide">
            รายละเอียดเมนูอาหาร
          </h1>

          <div className="bg-white rounded-lg shadow-lg p-6">
            <div className="mb-6 text-center">
              <h2 className="text-2xl font-semibold text-gray-800 mb-4">
                {menuData.menu_name}
              </h2>
              <div className="w-full h-64 overflow-hidden rounded-md shadow-sm">
                <img
                  src={menuData.image_url}
                  alt={menuData.menu_name}
                  className="w-full h-full object-contain"
                />
              </div>
            </div>

            {/* ประเภทอาหาร */}
            <div className="mb-6">
              <h3 className="text-lg font-medium text-blue-500 mb-2">
                ประเภทอาหาร:
              </h3>
              <p className="text-base text-gray-700 bg-gray-100 p-3 rounded-md shadow-inner">
                {menuData.category_name || "ไม่มีข้อมูลประเภท"}
              </p>
            </div>

            {/* โรคที่เหมาะสม */}
            <div className="mb-6">
              <h3 className="text-lg font-medium text-green-500 mb-2">
                โรคที่เหมาะสม:
              </h3>
              <p className="text-base text-gray-700 bg-green-100 p-3 rounded-md shadow-inner">
                {menuData.condition_name || "ไม่มีข้อมูลโรคที่เหมาะสม"}
              </p>
            </div>

            {/* วัตถุดิบ */}
            <div className="mb-6">
              <h3 className="text-lg font-medium text-purple-500 mb-2">
                วัตถุดิบ:
              </h3>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                {menuData.ingredients ? (
                  menuData.ingredients.split(", ").map((ingredient, index) => (
                    <div
                      key={index}
                      className="text-center p-3 bg-gray-50 rounded-md shadow-sm"
                    >
                      <div className="w-full h-24 overflow-hidden rounded-md">
                        <img
                          src={
                            menuData.ingredients_image
                              ? menuData.ingredients_image.split(", ")[index]
                              : "default-image-url"
                          }
                          alt={ingredient}
                          className="w-full h-full object-contain"
                        />
                      </div>
                      <p className="text-gray-800 mt-2">{ingredient}</p>
                    </div>
                  ))
                ) : (
                  <p className="text-gray-500">ไม่มีข้อมูลวัตถุดิบ</p>
                )}
              </div>
            </div>

            {/* เงื่อนไขสุขภาพ */}
            <div className="mb-6">
              <h3 className="text-lg font-medium text-red-500 mb-2">
                เงื่อนไขสุขภาพที่เกี่ยวข้อง:
              </h3>
              <ul className="list-disc pl-5 bg-red-50 p-4 rounded-md shadow-inner">
                {menuData.related_conditions ? (
                  menuData.related_conditions
                    .split(", ")
                    .map((condition, index) => (
                      <li key={index} className="mb-1 text-gray-800">
                        <strong className="text-red-500">{condition}:</strong>{" "}
                        {menuData.related_conditions_detail
                          ? menuData.related_conditions_detail.split(", ")[
                              index
                            ]
                          : "ไม่มีรายละเอียด"}
                      </li>
                    ))
                ) : (
                  <p className="text-gray-500">
                    ไม่มีข้อมูลเงื่อนไขสุขภาพที่เกี่ยวข้อง
                  </p>
                )}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FoodMenuDetail;
