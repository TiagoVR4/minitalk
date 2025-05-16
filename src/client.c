/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/14 15:23:06 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/05/17 00:19:44 by tiagovr4         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../minitalk.h"

// This function sends a character by sending each bit
static void	send_char(pid_t pid, char c)
{
	int	bit;

	bit = 0;
	while (bit < 8)
	{
		if ((c & (1 << bit)) != 0)
			kill(pid, SIGUSR1);					// Send 1
		else
			kill(pid, SIGUSR2);					// Send 0
		usleep(500);							// Wait for the server to process	
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
	send_string(server_pid, argv[2]);
	return (0);
}
