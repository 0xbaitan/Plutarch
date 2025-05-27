import { ALL_USER_KEYS, User, UserKeys } from "@/types";
import { gql, useQuery } from "urql";

import { get } from "http";

function getAllUsersQuery(params: UserKeys[] = ALL_USER_KEYS) {
  return gql`
    query {
      getAllUsers {
        id
      }
    }
  `;
}

function constructUserParamsString(params: UserKeys[] = ALL_USER_KEYS) {
  return params.join("\n");
}

export function useGetAllUsersQuery(params: UserKeys[] = ALL_USER_KEYS) {
  const allUsersQuery = getAllUsersQuery(params);
  return useQuery<Partial<User>[]>({
    query: allUsersQuery,
  });
}
