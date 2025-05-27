import { Client, cacheExchange, fetchExchange } from "urql";

export const apiClient = new Client({
  url: "http://localhost:6200/graphql",
  exchanges: [cacheExchange, fetchExchange],
});
