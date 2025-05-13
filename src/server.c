/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/09 18:39:44 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/05/13 16:53:21 by tiagovr4         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../minitalk.h"

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
		ft_putchar_fd(current_char, 1);
		if (current_char == '\0')
			ft_putchar_fd('\n', 1);
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
	ft_printf("Server PID: %d\n", getpid());
	setup_signals();
	while (1)
		pause();
	return (0);
}
