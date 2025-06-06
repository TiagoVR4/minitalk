/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/14 15:23:06 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/06/06 13:19:23 by tiagovr4         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../minitalk.h"

static int	g_bit_confirmed;

// Handle confirmation from server
static void	handle_confirmation(int sig)
{
	if (sig == SIGUSR1)
		g_bit_confirmed = 1;
}

// This function sends a character by sending each bit
static void	send_char(pid_t pid, char c)
{
	int	bit;

	bit = 0;
	while (bit < 8)
	{
		g_bit_confirmed = 0;
		if ((c & (1 << bit)) != 0)
		{
			if (kill(pid, SIGUSR1) == -1)
				exit(1);
		}
		else
		{
			if (kill(pid, SIGUSR2) == -1)
				exit(1);
		}
		while (!g_bit_confirmed)
			usleep(100);							// Wait for the server to process	
		bit++;
	}
}

// This function sends a string to the server character by character
static void	send_string(pid_t pid, char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
	{
		send_char(pid, str[i]);
		i++;
	}
	send_char(pid, '\0');
}

// Setup signal handles for confirmation
static void	setup_signals(void)
{
	struct sigaction	sa;
	
	sa.sa_handler = handle_confirmation;
	sa.sa_flags = 0;
	sigemptyset(&sa.sa_mask);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
	{
		ft_putstr_fd("Error setting up signal handler\n", 2);
		exit(1);
	}
}

int	main(int argc, char **argv)
{
	pid_t	server_pid;
	
	if (argc != 3)
	{
		ft_putstr_fd("Usage: ./client [server PID] [message]\n", 2);
		return (1);
	}
	server_pid = ft_atoi(argv[1]);
	if (server_pid <= 0)
	{
		ft_putstr_fd("Invalid PID\n", 2);
		return (1);
	}
	setup_signals();
	send_string(server_pid, argv[2]);
	return (0);
}
