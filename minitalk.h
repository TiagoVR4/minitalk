/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minitalk.h                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tiagovr4 <tiagovr4@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/09 13:47:15 by tiagovr4          #+#    #+#             */
/*   Updated: 2025/05/30 16:56:36 by tiagovr4         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MINITALK_H
# define MINITALK_H

# include <unistd.h>
# include <signal.h>
# include <stdlib.h>
# include "libft/libft.h"

typedef struct	s_message
{
	char	*buffer;
	size_t	size;
	size_t	len;
	int		bit;
	char	c;
}				t_message;

#endif