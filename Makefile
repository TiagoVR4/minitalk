# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/09 13:47:57 by tiagovr4          #+#    #+#              #
#    Updated: 2025/05/14 16:32:38 by tiagovr4         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #


# Define colors for output messages
RED = \033[1;31m
GRN = \033[1;32m
YLW = \033[1;33m
BLU = \033[1;34m
MGN = \033[1;35m
CYN = \033[1;36m
D = \033[0m

CLIENT = client
SERVER = server

# libft paths and source files
LIBFT_PATH = libft
LIBFT_ARC = $(LIBFT_PATH)/libft.a

# Include paths
INCLUDES = -I$(LIBFT_PATH) -Iincludes/

# Source directories
SRC_DIR = src
CLIENT_SRC = $(SRC_DIR)/client.c
SERVER_SRC = $(SRC_DIR)/server.c

# object files
CLIENT_OBJ = $(CLIENT_SRC:.c=.o)
SERVER_OBJ = $(SERVER_SRC:.c=.o)

# compiler and flags
CC = cc
CFLAGS = -Wall -Wextra -Werror -g $(INCLUDES)

# Main rule - build libft.a after dependencies are met
all: deps $(CLIENT) $(SERVER)

# Check and download dependencies if needed
deps: get_libft
	@echo "[$(GRN)Nothing to be done!$(D)]"

# Download libft if not present
get_libft:
	@if [ -d "$(LIBFT_PATH)" ]; then \
		echo "[$(GRN)libft$(D)] folder found 🖔"; \
		$(MAKE) -C $(LIBFT_PATH) deps; \
	else \
		echo "Getting $(YLW)libft$(D)"; \
		git clone git@github.com:TiagoVR4/libft.git; \
		$(MAKE) -C $(LIBFT_PATH) deps; \
		echo "$(GRN)Done downloading libft$(D)"; \
	fi
	
# Create client executable
$(CLIENT): $(CLIENT_OBJ) $(LIBFT_ARC)
	@echo "[$(CYN)Compiling$(D)] $(CLIENT)"
	@$(CC) $(CFLAGS) -o $(CLIENT) $(CLIENT_OBJ) -L$(LIBFT_PATH) -lft
	@echo "[$(GRN)Done!$(D)]"

PRINTF_ARC = $(LIBFT_PATH)/ft_printf/libftprintf.a

# Create server executable
$(SERVER): $(SERVER_OBJ) $(LIBFT_ARC) $(PRINTF_ARC)
	@echo "[$(CYN)Compiling$(D)] $(SERVER)"
	@$(CC) $(CFLAGS) -o $(SERVER) $(SERVER_OBJ) -L$(LIBFT_PATH) -lft -L$(LIBFT_PATH)/ft_printf -lftprintf
	@echo "[$(GRN)Done!$(D)]"

# Generic rule for compiling .c to .o
%.o: %.c
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -c $< -o $@

# compile libft
$(LIBFT_ARC):
	@echo "[$(CYN)Compiling$(D)] libft"
	@$(MAKE) -C $(LIBFT_PATH)
	@echo "[$(GRN)libft compiled successfully$(D)]"

# Clean up object files and the main executable
clean:
	@echo "[$(CYN)Cleaning$(D)]"	
	@rm -f $(CLIENT_OBJ) $(SERVER_OBJ)
	@$(MAKE) -C $(LIBFT_PATH) clean
	@echo "[$(GRN)Cleaned!$(D)]"

fclean: clean
	@echo "[$(CYN)Cleaning$(D)]"
	@rm -f $(CLIENT) $(SERVER)
	@$(MAKE) -C $(LIBFT_PATH) fclean
	@echo "[$(GRN)Cleaned!$(D)]"

# Rebuild everything from scratch
re: fclean all
	@echo "[$(CYN)Rebuilding$(D)]"
	@$(MAKE) all
	@echo "[$(GRN)Rebuild complete!$(D)]"

.PHONY: all clean fclean re deps get_libft