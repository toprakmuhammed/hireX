import { ConnectButton } from "@mysten/dapp-kit";
import { Flex, Box, Heading } from "@radix-ui/themes";

export function Navbar() {
  return (
    <Flex
      position="sticky"
      px="4"
      py="2"
      justify="between"
      style={{
        borderBottom: "1px solid var(--gray-a2)",
        backgroundColor: "var(--color-background)",
      }}
    >
      <Box>
        <Heading>HireX Platform</Heading>
      </Box>

      <Box>
        <ConnectButton />
      </Box>
    </Flex>
  );
}
