import mongoose from "mongoose";

const bookSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Book title is required"],
    },

    caption: {
      type: String,
      trim: true,
      maxlength: [1000, "Description must not exceed 1000 characters"],
    },

    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    image: {
      type: String,
      required: true,
    },
    // Optional: if you want to link books to users who created/added them
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

const Book = mongoose.model("Book", bookSchema);

export default Book;
