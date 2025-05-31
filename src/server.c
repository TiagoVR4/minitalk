/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/09 18:39:44 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/05/30 18:51:49 by tiagovr4         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../minitalk.h"

t_message	g_message;

static void	reallocate_buffer(void)
{
	char	*new_buffer;
	size_t	new_size;
	
	new_size = g_message.size == 0 ? 64 : g_message.size * 2;
	new_buffer = malloc(new_size);
	if (!new_buffer)
	{
		free(g_message.buffer);
		ft_putstr_fd("Memory allocation error\n", 2);
		exit(1);
	}
	if (g_message.buffer)
		ft_memcpy(new_buffer, g_message.buffer, g_message.len);
	free(g_message.buffer);
	g_message.buffer = new_buffer;
	g_message.size = new_size;
}

// This function collects all the characters before printing
static void	add_char_to_buffer(char c)
{
	if (g_message.len >= g_message.size)
		reallocate_buffer();
	g_message.buffer[g_message.len++] = c;
	if (c == '\0')
	{
		ft_printf("%s", g_message.buffer);
		ft_putchar_fd('\n', 1);
		free(g_message.buffer);
		g_message.buffer = NULL;
		g_message.size = 0;
		g_message.len = 0;
	}
}

// This funtion reconstructs the original message from the bits received.
static void	handle_bit(int sig)
{
	static int	bit_position = 0;
	static char	current_char = 0;

	if (sig == SIGUSR1)
		current_char |= (1<< bit_position);		// Set the bit
	bit_position++;
	if (bit_position == 8)
	{
		add_char_to_buffer(current_char);
		bit_position = 0;
		current_char = 0;
	}
}

static void	setup_signals(void)
{
	struct sigaction	sa;
	
	sa.sa_handler = handle_bit;
	sa.sa_flags = SA_RESTART;
	sigemptyset(&sa.sa_mask);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
	{
		ft_putstr_fd("Error setting up SIGUSR1 handler\n", 2);
		exit(1);
	}
	if (sigaction(SIGUSR2, &sa, NULL) == -1)
	{
		ft_putstr_fd("Error setting up SIGUSR2 handler\n", 2);
		exit(1);
	}
}

int	main(void)
{
	g_message.buffer = NULL;
	g_message.size = 0;
	g_message.len = 0;
	g_message.bit = 0;
	g_message.c = 0;
	
	ft_printf("Server PID: %d\n", getpid());
	setup_signals();
	while (1)
		pause();
	return (0);
}
