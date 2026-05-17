import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Merkato — East Africa's Premier Marketplace",
    template: "%s | Merkato",
  },
  description:
    "Discover quality products from trusted vendors across Ethiopia and Kenya. Shop electronics, fashion, food, and more with Telebirr and M-Pesa payments.",
  keywords: [
    "marketplace",
    "Ethiopia",
    "Kenya",
    "e-commerce",
    "Telebirr",
    "M-Pesa",
    "online shopping",
    "East Africa",
  ],
  openGraph: {
    type: "website",
    locale: "en_US",
    siteName: "Merkato",
    title: "Merkato — East Africa's Premier Marketplace",
    description:
      "Shop from trusted vendors across Ethiopia and Kenya with mobile money payments.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${inter.variable} h-full`} suppressHydrationWarning>
      <body className="min-h-full flex flex-col font-sans antialiased bg-background text-foreground">
        {children}
      </body>
    </html>
  );
}
