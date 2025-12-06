// src/App.tsx
import { Container } from "@radix-ui/themes";
import { Navbar } from "./components/Navbar"; // Oluşturduğumuz bileşeni çağırdık
import { useCurrentAccount } from "@mysten/dapp-kit";

function App() {
  const currentAccount = useCurrentAccount();

  return (
    <>
      <Navbar />

      <Container mt="5" pt="2" px="4">
        <main>
          {currentAccount ? (
            <div>Hoşgeldin, Cüzdan bağlı!</div>
          ) : (
            <div>Lütfen cüzdan bağlayın.</div>
          )}
        </main>
      </Container>
    </>
  );
}

export default App;
