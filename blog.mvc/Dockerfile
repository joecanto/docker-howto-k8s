FROM microsoft/aspnetcore-build:2.0 AS build-env

WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./blog.mvc/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY ./blog.mvc ./
RUN dotnet publish -c Release -o out

# Build runtime image
FROM microsoft/aspnetcore:2.0
WORKDIR /app
COPY --from=build-env /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "blog.mvc.dll"]