import { describe, expect, it } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";

import App from "./App";

describe("App", () => {
  it("increments the counter when button is clicked", () => {
    render(<App />);
    const counterButton = screen.getByRole("button", { name: /count is 0/i });
    fireEvent.click(counterButton);
    expect(screen.getByRole("button", { name: /count is 1/i })).toBeInTheDocument();
  });
});
