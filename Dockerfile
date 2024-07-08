# Debian based node 21.6 image
FROM node:21.6-bookworm as development

WORKDIR /app

COPY . .

RUN npm config set registry http://registry.npmjs.org/

RUN npm install

EXPOSE 3000

CMD [ "/bin/sh", "-c", "npm run dev" ]


# Intermediate image for building the application
FROM development as builder

WORKDIR /app

RUN NEXT_PUBLIC_ENABLE_ADMIN_LOGIN=true npm run build

# Final release image
FROM node:21.6-bookworm as production

WORKDIR /app

# Copy only the necessary files
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json .
COPY --from=builder /app/public ./public
COPY --from=builder /app/scripts ./scripts

# Install only production dependencies
RUN npm install --only=production --omit=dev

CMD [ "/bin/sh", "-c", "npm start" ]

EXPOSE 3000
