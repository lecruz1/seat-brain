def move_seat(position):
    if position > 100 or position < 0:
        raise ValueError("Position must be between 0 and 100")
    print(f"Moving seat to position: {position}")
    return True

if __name__ == "__main__":
    move_seat(50)