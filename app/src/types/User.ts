export type User = {
  id: number;
  username: String;
  email: String;
  firstName: String;
  lastName: String;
};

export type UserKeys = keyof User;

export const ALL_USER_KEYS: UserKeys[] = ["id", "username", "email", "firstName", "lastName"];
