import express from "express";
import cloudinary from "../lib/cloudinary.js";
import protectRoute from "../middleware/auth.middleware.js";
import Book from "../models/Book.js";

const router = express.Router();

// CREATE
router.post("/", protectRoute, async (req, res) => {
  try {
    const { title, caption, rating, image } = req.body;

    if (!title || !caption || !rating || !image) {
      return res.status(400).json({ message: "Please provide all fields" });
    }

    // upload image to Cloudinary
    const uploadResponse = await cloudinary.uploader.upload(image, {
      folder: "books",
    });
    const imageUrl = uploadResponse.secure_url;

    // save to database
    const newBook = new Book({
      title,
      caption,
      rating,
      image: imageUrl,
      user: req.user._id,
    });

    const savedBook = await newBook.save();

    res.status(201).json(savedBook);
  } catch (err) {
    console.error("Error creating book:", err);
    res.status(500).json({ message: err.message });
  }
});

router.get("/", protectRoute, async (req, res) => {
  try {
    // parse and validate pagination
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.max(1, parseInt(req.query.limit) || 5);
    const skip = (page - 1) * limit;

    // fetch books with pagination
    const books = await Book.find()
      .sort({ createdAt: -1 }) // latest first
      .skip(skip)
      .limit(limit)
      .populate("user", "username profileImage");

    // get total books count
    const totalBooks = await Book.countDocuments();

    // send response
    res.json({
      books,
      currentPage: page,
      totalBooks,
      totalPages: Math.ceil(totalBooks / limit),
    });
  } catch (error) {
    console.error("Error in get all books route:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// DELETE a book
router.delete("/:id", protectRoute, async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);

    if (!book) {
      return res.status(404).json({ message: "Book not found" });
    }

    // check ownership
    if (book.user.toString() !== req.user._id.toString()) {
      return res
        .status(403)
        .json({ message: "Not authorized to delete this book" });
    }

    if (book.image && book.image.includes("cloudinary")) {
      try {
        const publicId = book.image.split("/").pop().split(".")[0];
        await cloudinary.uploader.destroy(publicId);
      } catch (deleteError) {
        console.log("Error deleting image from cloudinary", deleteError);
      }
    }

    await book.deleteOne();

    res.json({ message: "Book deleted successfully" });
  } catch (error) {
    console.error("Error deleting book:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// get all books created by the logged-in user
router.get("/user", protectRoute, async (req, res) => {
  try {
    const books = await Book.find({ user: req.user._id }).sort({
      createdAt: -1,
    }); // newest first

    if (!books || books.length === 0) {
      return res.status(404).json({ message: "No books found for this user" });
    }

    res.json(books);
  } catch (error) {
    console.error("Get user books error:", error.message);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;
