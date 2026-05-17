import React from "react";

/**
 * Auth layout — centered card design for login, register, forgot-password.
 * Shared across all (auth) routes.
 */
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-dark via-primary to-primary-light p-4">
      {/* Decorative background pattern */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-1/4 -right-1/4 w-1/2 h-1/2 bg-white/5 rounded-full blur-3xl" />
        <div className="absolute -bottom-1/4 -left-1/4 w-1/2 h-1/2 bg-white/5 rounded-full blur-3xl" />
      </div>

      <div className="relative w-full max-w-md">
        {/* Logo */}
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-white tracking-tight">
            Merkato
          </h1>
          <p className="mt-2 text-white/70 text-sm">
            East Africa&apos;s Premier Marketplace
          </p>
        </div>

        {/* Card */}
        <div className="bg-card rounded-2xl shadow-2xl border border-white/10 p-8 backdrop-blur-sm">
          {children}
        </div>

        {/* Footer */}
        <p className="mt-6 text-center text-white/50 text-xs">
          © {new Date().getFullYear()} Merkato. All rights reserved.
        </p>
      </div>
    </div>
  );
}
