/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagalex <tiagalex@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/09 18:39:44 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/06/22 20:28:01 by tiagalex         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../minitalk.h"

t_message	g_message;

// This funtion Print the full message and reset the buffer.
static void	show_and_release(void)
{
	if (!g_message.buffer)
	{
		g_message.size = 0;
		g_message.len = 0;
		signal(SIGUSR1, handle_bit);
		signal(SIGUSR2, handle_bit);
	}
	else
	{
		g_message.buffer[g_message.size] = '\0';
		ft_printf("%s\n", g_message.buffer);
		free(g_message.buffer);
		g_message.buffer = NULL;
		g_message.size = 0;
		g_message.len = 0;
	}
}

// this funtion reconstructs the original message
static void	handle_message(int sig)
{
	static unsigned char	received_char = 0;
	static int				bit_counter = 0;

	if (sig == SIGUSR1)
		received_char |= (1 << bit_counter);
	bit_counter++;
	if (bit_counter == 8)
	{
		if (g_message.buffer == NULL)
			g_message.buffer = ft_calloc((g_message.size + 1), sizeof(char));
		g_message.buffer[g_message.len] = received_char;
		g_message.len++;
		bit_counter = 0;
		received_char = 0;
	}
	if (g_message.len == g_message.size)
		show_and_release();
}

// This funtion reconstructs the size of the original message
void	handle_bit(int sig)
{
	static unsigned int	char_size = 0;
	static int			bit_position = 0;

	if (sig == SIGUSR1)
		char_size |= (1 << bit_position);
	bit_position++;
	if (bit_position == 32)
	{
		if (char_size > 1048576 || char_size == 0)
		{
			ft_putstr_fd("Error: Message size is too big\n", 2);
			char_size = 1024;
		}
		g_message.size = char_size;
		signal(SIGUSR1, handle_message);
		signal(SIGUSR2, handle_message);
		bit_position = 0;
		char_size = 0;
	}
}

int	main(void)
{
	g_message.buffer = NULL;
	g_message.size = 0;
	g_message.len = 0;
	ft_printf("Server PID: %d\n", getpid());
	signal(SIGUSR1, handle_bit);
	signal(SIGUSR2, handle_bit);
	while (1)
		pause();
	return (0);
}
