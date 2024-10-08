import React, { useState, useEffect } from "react";
import axios from "axios";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import Swal from "sweetalert2";
import { useNavigate } from "react-router-dom";

const FoodMenuAdd = () => {
  const [menuName, setMenuName] = useState("");
  const [category, setCategory] = useState(""); // จะเก็บ category_id ที่เลือก
  const [categories, setCategories] = useState([]);
  const [imageUrl, setImageUrl] = useState("");
  const [healthCondition, setHealthCondition] = useState(""); // จะเก็บ health_condition_id ที่เลือก
  const [healthConditions, setHealthConditions] = useState([]);
  const [relatedConditions, setRelatedConditions] = useState([]); // จะเก็บ related_conditions ที่เลือก (id)
  const [selectedRelatedConditions, setSelectedRelatedConditions] = useState(
    []
  ); // เก็บเฉพาะ id ของโรคที่เลือก
  const [ingredients, setIngredients] = useState([]);
  const [selectedIngredients, setSelectedIngredients] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const navigate = useNavigate();

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}`
        );
        setCategories(response.data);
      } catch (err) {
        console.error("Error fetching categories:", err);
      }
    };

    const fetchHealthConditions = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_DISEASES}`
        );
        setHealthConditions(response.data);
      } catch (err) {
        console.error("Error fetching health conditions:", err);
      }
    };

    const fetchIngredients = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_INGREDIENTS}`
        );
        setIngredients(response.data);
      } catch (err) {
        console.error("Error fetching ingredients:", err);
      }
    };

    fetchCategories();
    fetchHealthConditions();
    fetchIngredients();
  }, []);

  const handleIngredientChange = (ingredient) => {
    setSelectedIngredients((prevSelected) => {
      if (prevSelected.includes(ingredient)) {
        return prevSelected.filter((item) => item !== ingredient);
      } else {
        return [...prevSelected, ingredient];
      }
    });
  };

  const handleRemoveIngredient = (ingredient) => {
    setSelectedIngredients((prevSelected) =>
      prevSelected.filter((item) => item !== ingredient)
    );
  };

  // ฟังก์ชันจัดการการเลือกโรคที่เกี่ยวข้อง
  const handleRelatedConditionChange = (conditionId) => {
    setSelectedRelatedConditions((prevSelected) => {
      if (prevSelected.includes(conditionId)) {
        return prevSelected.filter((item) => item !== conditionId);
      } else {
        return [...prevSelected, conditionId];
      }
    });
  };

  // ฟังก์ชันลบโรคที่เลือก
  const handleRemoveRelatedCondition = (conditionId) => {
    setSelectedRelatedConditions((prevSelected) =>
      prevSelected.filter((item) => item !== conditionId)
    );
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    // ตรวจสอบความถูกต้องของข้อมูล
    if (
      !menuName ||
      !imageUrl ||
      !category || // ตรวจสอบว่า category_id ถูกเลือก
      !healthCondition || // ตรวจสอบว่า health_condition_id ถูกเลือก
      selectedIngredients.length === 0 ||
      selectedRelatedConditions.length === 0 // ตรวจสอบว่ามีการเลือกโรคที่เกี่ยวข้อง
    ) {
      setError({
        message:
          "กรุณากรอกข้อมูลในทุกฟิลด์และเลือกวัตถุดิบและโรคที่เกี่ยวข้องอย่างน้อยหนึ่งรายการ",
      });
      return;
    }

    setLoading(true);

    const formData = {
      menu_name: menuName,
      category: category, // ส่ง category_id ไปยังเซิร์ฟเวอร์
      image_url: imageUrl,
      health_condition: healthCondition, // ส่ง health_condition_id ไปยังเซิร์ฟเวอร์
      ingredients: selectedIngredients.map((item) => item.ingredient_id),
      related_conditions: selectedRelatedConditions, // ส่ง id ของโรคที่เกี่ยวข้องไปยังเซิร์ฟเวอร์
    };

    console.log("Data to be sent:", formData);

    try {
      await axios.post(
        `${import.meta.env.VITE_API_URL_ADD_FOOD_MENU}`,
        formData
      );
      Swal.fire({
        icon: "success",
        title: "เพิ่มเมนูอาหารสำเร็จ!",
        text: "ข้อมูลได้ถูกบันทึกแล้ว",
      }).then(() => {
        // หลังจากการแสดงผลเสร็จสิ้นให้ไปยัง /foodmenu
        navigate("/foodmenu");
      });

      setMenuName("");
      setCategory("");
      setImageUrl("");
      setHealthCondition("");
      setSelectedIngredients([]);
      setSelectedRelatedConditions([]);
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  };

  const filteredIngredients = ingredients.filter((ingredient) =>
    ingredient.ingredient_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-300">
      <Sidebar isSidebarOpen={isSidebarOpen} />
      <div className="flex-1 p-10">
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-5xl font-bold text-center mb-12 text-gray-900">
          เพิ่มเมนูอาหาร
        </h1>

        <form
          onSubmit={handleSubmit}
          className="max-w-6xl mx-auto bg-white p-10 rounded-xl shadow-2xl"
        >
          <div className="grid grid-cols-1 md:grid-cols-2 gap-10 mb-10">
            <div>
              <label className="block text-xl text-gray-700 mb-3">
                ชื่อเมนูอาหาร:
              </label>
              <input
                type="text"
                value={menuName}
                onChange={(e) => setMenuName(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              />
            </div>

            <div>
              <label className="block text-xl text-gray-700 mb-3">
                ลิงก์รูปภาพเมนู:
              </label>
              <input
                type="text"
                value={imageUrl}
                onChange={(e) => setImageUrl(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              />
            </div>

            <div>
              <label className="block text-xl text-gray-700 mb-3">
                ประเภทอาหาร:
              </label>
              <select
                value={category} // เก็บ category_id แทน
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              >
                <option value="">-- เลือกประเภทอาหาร --</option>
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>
                    {cat.category_name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xl text-gray-700 mb-3">
                เหมาะสมกับโรค:
              </label>
              <select
                value={healthCondition} // เก็บ health_condition_id แทน
                onChange={(e) => setHealthCondition(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              >
                <option value="">-- เลือกโรคที่เหมาะสม --</option>
                {healthConditions.map((condition) => (
                  <option
                    key={condition.condition_id}
                    value={condition.condition_id}
                  >
                    {condition.condition_name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* ส่วนเลือกโรคที่เกี่ยวข้อง */}
          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-3">
              โรคที่เกี่ยวข้อง:
            </label>
            <div className="p-4 border rounded-lg bg-gray-100 flex flex-wrap gap-3">
              {selectedRelatedConditions.length > 0 ? (
                selectedRelatedConditions.map((conditionId, index) => {
                  const condition = healthConditions.find(
                    (c) => c.condition_id === conditionId
                  );
                  return (
                    <div
                      key={index}
                      className="flex items-center bg-green-200 text-green-800 px-3 py-1 rounded-full text-sm font-semibold mr-2 mb-2"
                    >
                      {condition?.condition_name}
                      <button
                        className="ml-2 text-red-500 hover:text-red-700"
                        onClick={() =>
                          handleRemoveRelatedCondition(conditionId)
                        }
                      >
                        &times;
                      </button>
                    </div>
                  );
                })
              ) : (
                <p className="text-gray-500">ยังไม่มีโรคที่ถูกเลือก</p>
              )}
            </div>
          </div>

          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-5">
              เลือกโรคที่เกี่ยวข้อง:
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 max-h-96 overflow-y-auto">
              {healthConditions.map((condition) => (
                <div
                  key={condition.condition_id}
                  className={`flex flex-col items-center p-4 border rounded-lg shadow-sm transition duration-300 cursor-pointer ${
                    selectedRelatedConditions.includes(condition.condition_id)
                      ? "bg-green-100 border-green-500"
                      : "bg-white hover:shadow-lg"
                  }`}
                  onClick={() =>
                    handleRelatedConditionChange(condition.condition_id)
                  }
                >
                  <span className="text-center text-sm font-semibold mb-2">
                    {condition.condition_name}
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className="mb-8">
            <label className="block text-xl text-gray-700 mb-3">
              ค้นหาวัตถุดิบ:
            </label>
            <input
              type="text"
              placeholder="ค้นหาวัตถุดิบ..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
            />
          </div>

          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-3">
              วัตถุดิบของเมนู:
            </label>
            <div className="p-4 border rounded-lg bg-gray-100 flex flex-wrap gap-3">
              {selectedIngredients.length > 0 ? (
                selectedIngredients.map((ingredient, index) => (
                  <div
                    key={index}
                    className="flex items-center bg-blue-200 text-blue-800 px-3 py-1 rounded-full text-sm font-semibold mr-2 mb-2"
                  >
                    {ingredient.ingredient_name}
                    <button
                      className="ml-2 text-red-500 hover:text-red-700"
                      onClick={() => handleRemoveIngredient(ingredient)}
                    >
                      &times;
                    </button>
                  </div>
                ))
              ) : (
                <p className="text-gray-500">ยังไม่มีวัตถุดิบที่ถูกเลือก</p>
              )}
            </div>
          </div>

          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-5">
              วัตถุดิบ:
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 max-h-96 overflow-y-auto">
              {filteredIngredients.map((ingredient) => (
                <div
                  key={ingredient.ingredient_id}
                  className={`flex flex-col items-center p-4 border rounded-lg shadow-sm transition duration-300 cursor-pointer ${
                    selectedIngredients.includes(ingredient)
                      ? "bg-blue-100 border-blue-500"
                      : "bg-white hover:shadow-lg"
                  }`}
                  onClick={() => handleIngredientChange(ingredient)}
                >
                  <img
                    src={ingredient.image_url}
                    alt={ingredient.ingredient_name}
                    className="w-24 h-24 object-cover mb-3 rounded-lg"
                  />
                  <span className="text-center text-sm font-semibold mb-2">
                    {ingredient.ingredient_name}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {error && (
            <div className="text-red-600 mb-4 text-center">{error.message}</div>
          )}
          {success && (
            <div className="text-green-600 mb-4 text-center">{success}</div>
          )}

          <button
            type="submit"
            className="w-full py-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg text-xl font-bold hover:from-blue-600 hover:to-purple-600 transition duration-300 shadow-lg hover:shadow-2xl"
            disabled={loading}
          >
            {loading ? "กำลังบันทึก..." : "เพิ่มเมนู"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default FoodMenuAdd;
